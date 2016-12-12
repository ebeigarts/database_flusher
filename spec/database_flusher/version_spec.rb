# frozen_string_literal: true
require 'spec_helper'

describe 'DatabaseFlusher::VERSION' do
  it 'returns version number' do
    expect(DatabaseFlusher::VERSION).not_to be nil
  end
end
