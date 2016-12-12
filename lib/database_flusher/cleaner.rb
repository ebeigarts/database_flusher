module DatabaseFlusher
  class Cleaner
    attr_reader :strategy

    def initialize(orm)
      @orm = orm
      reset_strategy
    end

    def strategy=(name)
      strategy_changed = name != @strategy_name

      @strategy.stop if strategy_changed && @strategy

      if name
        create_strategy(name) if strategy_changed
      else
        reset_strategy
      end
    end

    def clean_with(name)
      self.strategy = name
      strategy.clean
    end

    private

    def create_strategy(name)
      @strategy_name = name
      @strategy = DatabaseFlusher.
        const_get(classify(@orm)).
        const_get("#{classify(name)}Strategy").new
    end

    def reset_strategy
      @strategy_name = nil
      @strategy = DatabaseFlusher::NullStrategy.new
    end

    def classify(name)
      name.to_s.split('_').collect{ |w| w.capitalize }.join
    end
  end
end
