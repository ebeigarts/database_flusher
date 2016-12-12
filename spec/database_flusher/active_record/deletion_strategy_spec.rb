require 'spec_helper'

describe DatabaseFlusher::ActiveRecord::DeletionStrategy do
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
        expect(cleaner.tables.to_a).to eq(['posts', 'comments'])
      ensure
        cleaner.clean
      end
      expect(ActiveRecordPost.count).to eq(0)
      expect(ActiveRecordComment.count).to eq(0)

      cleaner.stop
      ActiveRecordPost.create!
      expect(cleaner.tables.to_a).to eq([])
      cleaner.clean
      expect(ActiveRecordPost.count).to eq(1)
    end
  end
end
