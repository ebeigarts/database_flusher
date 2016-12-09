require "database_flusher/version"
require "set"

module DatabaseFlusher
  extend self

  def cleaners
    @cleaners ||= {}
  end

  # TODO: classify
  def [](name)
    cleaners[name] ||= DatabaseFlusher.const_get("#{name.to_s.classify}Cleaner").new
  end

  def clean
    cleaners.values.each { |cleaner| cleaner.clean }
  end

  class MongoSubscriber
    def initialize(cleaner)
      @cleaner = cleaner
    end

    def started(event)
      if event.command_name == :insert
        collection = event.command['insert'.freeze]
        if collection
          @cleaner.collections << collection
        end
      end
    end

    private

    def method_missing(*args, &block)
      # puts args.inspect
    end
  end

  class MongoCleaner
    attr_accessor :strategy
    attr_reader :collections

    def initialize
      @collections = Set.new
      Mongo::Monitoring::Global.subscribe(
        Mongo::Monitoring::COMMAND,
        MongoSubscriber.new(self)
      )
    end

    def clean
      return unless strategy
      client = Mongoid::Clients.default
      puts "Cleaning #{collections.inspect}"
      collections.each do |name|
        client[name].delete_many
      end
      collections.clear
    end
  end

  class ActiveRecordSubscriber
    def initialize(cleaner)
      @cleaner = cleaner
    end

    def call(_, _, _, _, payload)
      sql = payload[:sql]
      match = sql.match(/\A\s*INSERT(?:\s+IGNORE)?(?:\s+INTO)?\s+(?:\.*[`"]?([^.\s`"]+)[`"]?)*/i)
      return unless match
      table = match[1]
      if table
        @cleaner.tables << table
      end
    end
  end

  class ActiveRecordCleaner
    attr_accessor :strategy
    attr_reader :tables

    def initialize
      @tables = Set.new
      ActiveSupport::Notifications.subscribe(
        'sql.active_record',
        ActiveRecordSubscriber.new(self)
      )
    end

    def clean
      return unless strategy
      connection = ActiveRecord::Base.connection
      puts "Cleaning #{tables.inspect}"
      connection.disable_referential_integrity do
        stmts = tables.map { |t| "DELETE FROM #{connection.quote_table_name(t)}" }
        connection.execute stmts.join('; ')
      end
      tables.clear
    end
  end
end
