# frozen_string_literal: true
require 'spec_helper'

describe DatabaseFlusher::ActiveRecord::TransactionStrategy do
  subject!(:cleaner) { described_class.new }

  after do
    ActiveRecordPost.delete_all
    ActiveRecordComment.delete_all
  end

  describe '#clean' do
    it 'cleans the database' do
      begin
        cleaner.start
        ActiveRecordPost.create!
        ActiveRecordComment.create!
      ensure
        cleaner.clean
      end
      expect(ActiveRecordPost.count).to eq(0)
      expect(ActiveRecordComment.count).to eq(0)

      cleaner.stop
      ActiveRecordPost.create!
      cleaner.clean
      expect(ActiveRecordPost.count).to eq(1)
    end
  end
end
