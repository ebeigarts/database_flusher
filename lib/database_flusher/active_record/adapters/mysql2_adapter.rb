# frozen_string_literal: true
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
        execute sql
        raw_connection.abandon_results!
      end
    end
  end
end
