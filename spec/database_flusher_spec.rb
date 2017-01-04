# frozen_string_literal: true
require 'spec_helper'

describe DatabaseFlusher do
  describe '#cleaning' do
    it 'calls #start, yields a block, and calls #clean' do
      expect(DatabaseFlusher).to receive(:start)
      expect(DatabaseFlusher).to receive(:clean)
      result = 0
      DatabaseFlusher.cleaning { result = 1 }
      expect(result).to eq(1)
    end

    it 'calls #clean if block yields an error' do
      expect(DatabaseFlusher).to receive(:start)
      expect(DatabaseFlusher).to receive(:clean)
      result = 0
      expect {
        DatabaseFlusher.cleaning { raise "Error" }
      }.to raise_error(RuntimeError)
    end
  end
end
