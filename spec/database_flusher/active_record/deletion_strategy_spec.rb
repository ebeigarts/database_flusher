# frozen_string_literal: true
require 'spec_helper'

describe DatabaseFlusher::ActiveRecord::DeletionStrategy do
  subject!(:cleaner) { described_class.new }

  after do
    ActiveRecordPost.delete_all
    ActiveRecordComment.delete_all
  end

  describe '#clean_all' do
    it 'cleans the whole database' do
      ActiveRecordPost.create!
      ActiveRecordComment.create!
      cleaner.clean_all
      expect(ActiveRecordPost.count).to eq(0)
      expect(ActiveRecordComment.count).to eq(0)
    end
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

    if ENV['DB'] == 'mysql2'
      it 'cleans the database when table name is prefixed with schema' do
        posts = Class.new(ActiveRecordPost) do
          self.table_name = 'database_flusher.posts'
        end
        begin
          cleaner.start
          posts.create!
          expect(cleaner.tables.to_a).to eq(['database_flusher.posts'])
        ensure
          cleaner.clean
        end
        expect(posts.count).to eq(0)
      end
    end

    if ENV['DB'] == 'postgresql'
      it 'cleans the database when table name is prefixed with schema' do
        posts = Class.new(ActiveRecordPost) do
          self.table_name = 'public.posts'
        end
        begin
          cleaner.start
          posts.create!
          expect(cleaner.tables.to_a).to eq(['public.posts'])
        ensure
          cleaner.clean
        end
        expect(posts.count).to eq(0)
      end
    end
  end
end
