module RailsSoftDeletable
  class Association
    attr_reader :model
    attr_reader :target
    attr_reader :result

    def initialize(model, target, result)
      @model = model
      @target = target
      @result = result

      result.options[:with_deleted] = true
    end

    def build
      raise NotImplementedError, "Subclass must implement this method"
    end
  end
end
