module RailsSoftDeletable
  class Association
    attr_reader :record
    attr_reader :target
    attr_reader :result

    def initialize(record, target, result)
      @record = record
      @target = target
      @result = result

      result.options[:with_deleted] = true
    end

    def build
      raise NotImplementedError, "Subclass must implement this method"
    end
  end
end
