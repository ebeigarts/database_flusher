# frozen_string_literal: true
module DatabaseFlusher
  module ActiveRecord
    class TransactionStrategy
      def start
        # Hack to make sure that the connection is properly setup for
        # the clean code.
        ::ActiveRecord::Base.connection.transaction{ }

        ::ActiveRecord::Base.connection.begin_transaction joinable: false
      end

      def stop
        ::ActiveRecord::Base.connection_pool.connections.each do |connection|
          next unless connection.open_transactions > 0
          connection.rollback_transaction
        end
      end

      def clean
        stop
      end
    end
  end
end
