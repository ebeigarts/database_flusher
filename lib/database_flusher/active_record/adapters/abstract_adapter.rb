module DatabaseFlusher
  module ActiveRecord
    class AbstractAdapter
      attr_reader :connection, :raw_connection

      def initialize(connection)
        @connection = connection
        @raw_connection = connection.raw_connection
      end

      def delete(*tables)
        disable_referential_integrity(*tables) do
          stmts = tables.map do |name|
            "DELETE FROM #{quote_table_name(name)}"
          end
          sql = stmts.join(';')
          execute_multi sql
        end
      end

      private

      def execute_multi(sql)
        connection.execute sql
      end

      def execute(sql)
        connection.execute sql
      end

      def quote_table_name(name)
        connection.quote_table_name(name)
      end

      def disable_referential_integrity(*tables, &block)
        connection.disable_referential_integrity(&block)
      end
    end
  end
end
