# frozen_string_literal: true
module DatabaseFlusher
  module Mongoid
    class DeletionStrategy
      attr_reader :collections

      class Subscriber
        def initialize(strategy)
          @strategy = strategy
        end

        def started(event)
          collection = event.command['insert'.freeze]
          if collection
            @strategy.collections << collection
          end
        end

        private

        def method_missing(*args, &block)
        end
      end

      def initialize
        @collections = Set.new
      end

      def start
        @subscriber ||= client.subscribe(
          Mongo::Monitoring::COMMAND,
          Subscriber.new(self)
        )
      end

      def stop
        raise NotImplementedError, "Mongo doesn't provide unsubscribe"
      end

      def clean
        return if collections.empty?
        # puts "Cleaning #{collections.inspect}"
        collections.each do |name|
          client[name].delete_many
        end
        collections.clear
      end

      def clean_all
        all_collections.each do |name|
          client[name].delete_many
        end
      end

      private

      def client
        @client ||= ::Mongoid::Clients.default
      end

      def all_collections
        client.database.collections.collect { |c| c.namespace.split('.',2)[1] }
      end
    end
  end
end
