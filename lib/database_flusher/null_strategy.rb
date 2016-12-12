# frozen_string_literal: true
module DatabaseFlusher
  class NullStrategy
    def start; end
    def stop; end
    def clean; end
  end
end
