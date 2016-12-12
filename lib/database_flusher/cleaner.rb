module DatabaseFlusher
  class Cleaner
    attr_reader :strategy

    def initialize(orm)
      @orm = orm
      reset_strategy
    end

    def strategy=(name)
      strategy_changed = name != @strategy_name

      stop if strategy_changed

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

    def start
      strategy.start
    end

    def stop
      strategy.stop
    end

    def clean
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
      name.to_s.split('_').collect(&:capitalize).join
    end
  end
end
