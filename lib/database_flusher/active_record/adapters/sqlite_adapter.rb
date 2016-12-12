module DatabaseFlusher
  module ActiveRecord
    class SQLiteAdapter < AbstractAdapter
      private

      def execute_multi(sql)
        raw_connection.execute_batch sql
      end
    end
  end
end
