# frozen_string_literal: true
require 'spec_helper'

describe DatabaseFlusher::Mongoid::DeletionStrategy do
  subject!(:cleaner) { described_class.new }

  after do
    MongoidPost.delete_all
    MongoidComment.delete_all
  end

  describe '#clean_all' do
    it 'cleans the whole database' do
      MongoidPost.create!
      MongoidComment.create!
      cleaner.clean_all
      expect(MongoidPost.count).to eq(0)
      expect(MongoidComment.count).to eq(0)
    end
  end

  describe '#clean' do
    it 'cleans the database' do
      cleaner.start
      MongoidPost.create!
      MongoidComment.create!
      expect(cleaner.collections.to_a).to eq(['posts', 'comments'])
      cleaner.clean
      expect(MongoidPost.count).to eq(0)
      expect(MongoidComment.count).to eq(0)

      expect { cleaner.stop }.to raise_error(NotImplementedError)
    end
  end
end
