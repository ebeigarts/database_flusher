require 'spec_helper'
require 'active_record'

describe DatabaseFlusher::Cleaner do
  describe '#strategy=' do
    it 'sets strategy' do
      DatabaseFlusher[:active_record].strategy = nil
      expect(DatabaseFlusher[:active_record].strategy).to be_kind_of(
        DatabaseFlusher::NullStrategy
      )
      DatabaseFlusher[:active_record].strategy = :deletion
      expect(DatabaseFlusher[:active_record].strategy).to be_kind_of(
        DatabaseFlusher::ActiveRecord::DeletionStrategy
      )
      DatabaseFlusher[:active_record].strategy = nil
      expect(DatabaseFlusher[:active_record].strategy).to be_kind_of(
        DatabaseFlusher::NullStrategy
      )
    end

    it 'stops previous strategy' do
      DatabaseFlusher[:active_record].strategy = :deletion
      strategy = DatabaseFlusher[:active_record].strategy
      expect(strategy).to receive(:stop)
      DatabaseFlusher[:active_record].strategy = nil
    end
  end
end
