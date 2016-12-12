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
          if event.command_name == :insert || event.command_name == 'insert'.freeze
            collection = event.command['insert'.freeze]
            if collection
              @strategy.collections << collection
            end
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
        @subscriber ||= Mongo::Monitoring::Global.subscribe(
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
          client = ::Mongoid::Clients.default
          client[name].delete_many
        end
        collections.clear
      end
    end
  end
end
