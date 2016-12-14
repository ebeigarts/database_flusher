# frozen_string_literal: true
module DatabaseFlusher
  module ActiveRecord
    class PostgreSQLAdapter < AbstractAdapter
      private

      def disable_referential_integrity(*tables)
        execute(tables.collect { |name| "ALTER TABLE #{quote_table_name(name)} DISABLE TRIGGER ALL" }.join(";"))
        yield
      ensure
        execute(tables.collect { |name| "ALTER TABLE #{quote_table_name(name)} ENABLE TRIGGER ALL" }.join(";"))
      end
    end
  end
end
