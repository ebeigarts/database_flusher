# frozen_string_literal: true
require 'database_flusher/active_record/adapters/abstract_adapter'
require 'database_flusher/active_record/adapters/mysql2_adapter'
require 'database_flusher/active_record/adapters/postgresql_adapter'
require 'database_flusher/active_record/adapters/sqlite_adapter'

module DatabaseFlusher
  module ActiveRecord
    class DeletionStrategy
      attr_reader :tables

      class Subscriber
        # INSERT [IGNORE] [INTO] schema_name.table_name
        PATTERN = %r{
          \A\s*
          INSERT
          (?:\s+IGNORE)?
          (?:\s+INTO)?
          \s+
          (?:[`"]?([^.\s`"]+)[`"]?\.)? # schema
          (?:[`"]?([^.\s`"]+)[`"]?)    # table
        }xi

        def initialize(strategy)
          @strategy = strategy
        end

        def call(_, _, _, _, payload)
          sql = payload[:sql]
          match = sql.match(PATTERN)
          return unless match
          table  = match[2]
          if table
            schema = match[1]
            if schema
              table = "#{schema}.#{table}"
            end
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

      def clean_all
        adapter.delete(*all_tables)
      end

      private

      def connection
        @connection ||= ::ActiveRecord::Base.connection
      end

      def adapter
        @adapter ||= DatabaseFlusher::ActiveRecord.
          const_get("#{connection.adapter_name}Adapter").
          new(connection)
      end

      def all_tables
        # NOTE connection.tables warns on AR 5 with some adapters
        tables = ActiveSupport::Deprecation.silence { connection.tables }
        tables.reject do |t|
          (t == ::ActiveRecord::Migrator.schema_migrations_table_name) ||
          (::ActiveRecord::Base.respond_to?(:internal_metadata_table_name) &&
            (t == ::ActiveRecord::Base.internal_metadata_table_name))
        end
      end
    end
  end
end
