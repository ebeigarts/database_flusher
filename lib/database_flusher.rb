# frozen_string_literal: true
require 'set'

require 'database_flusher/version'
require 'database_flusher/null_strategy'
require 'database_flusher/cleaner'

require 'database_flusher/active_record/deletion_strategy'
require 'database_flusher/active_record/transaction_strategy'
require 'database_flusher/mongoid/deletion_strategy'

module DatabaseFlusher
  extend self

  def cleaners
    @cleaners ||= {}
  end

  def [](name)
    cleaners[name] ||= DatabaseFlusher::Cleaner.new(name)
  end

  def start
    cleaners.values.each(&:start)
  end

  def stop
    cleaners.values.each(&:stop)
  end

  def clean
    cleaners.values.each(&:clean)
  end

  def cleaning
    start
    yield
  ensure
    clean
  end
end
