module RailsSoftDeletable
  class Association
    attr_reader :record
    attr_reader :target
    attr_reader :reflection

    def initialize(record, target, reflection)
      @record = record
      @target = target
      @reflection = reflection

      reflection.options[:with_deleted] = true
    end

    def build
      raise NotImplementedError, "Subclass must implement this method"
    end
  end
end
