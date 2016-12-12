module DatabaseFlusher
  module ActiveRecord
    class Mysql2Adapter < AbstractAdapter
      def initialize(connection)
        super
        flags = raw_connection.query_options[:flags]
        unless flags.include?('MULTI_STATEMENTS'.freeze)
          raise 'MULTI_STATEMENTS flag is not enabled'
        end
      end

      private

      def execute_multi(sql)
        connection.disable_referential_integrity do
          _result = raw_connection.query sql
          while raw_connection.next_result
            # just to make sure that all queries are finished
            _result = raw_connection.store_result
          end
        end
      end
    end
  end
end
