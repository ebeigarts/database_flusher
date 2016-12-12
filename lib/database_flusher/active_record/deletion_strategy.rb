# frozen_string_literal: true
require 'database_flusher/active_record/adapters/abstract_adapter'
require 'database_flusher/active_record/adapters/mysql2_adapter'
require 'database_flusher/active_record/adapters/postgresql_adapter'
require 'database_flusher/active_record/adapters/sqlite_adapter'

module DatabaseFlusher
  module ActiveRecord
    class DeletionStrategy
      attr_reader :tables, :adapter

      class Subscriber
        def initialize(strategy)
          @strategy = strategy
        end

        def call(_, _, _, _, payload)
          sql = payload[:sql]
          match = sql.match(/\A\s*INSERT(?:\s+IGNORE)?(?:\s+INTO)?\s+(?:\.*[`"]?([^.\s`"]+)[`"]?)*/i)
          return unless match
          table = match[1]
          if table
            @strategy.tables << table
          end
        end
      end

      def initialize
        @tables = Set.new
      end

      def start
        @subscriber ||= ActiveSupport::Notifications.subscribe(
          'sql.active_record',
          Subscriber.new(self)
        )
        connection = ::ActiveRecord::Base.connection
        @adapter = DatabaseFlusher::ActiveRecord.
          const_get("#{connection.adapter_name}Adapter").
          new(connection)
      end

      def stop
        if @subscriber
          ActiveSupport::Notifications.unsubscribe(@subscriber)
          @subscriber = nil
        end
      end

      def clean
        return if tables.empty?

        # puts "Cleaning #{tables.inspect}"
        adapter.delete(*tables)

        tables.clear
      end
    end
  end
end
