require "active_support/concern"

module RailsSoftDeletable
  module Query
    extend ActiveSupport::Concern

    included do
      alias :deleted :only_deleted
    end

    def soft_deletable?
      true
    end

    def with_deleted
      scoped.tap { |x| x.default_scoped = false }
    end

    def only_deleted
      with_deleted.where("#{self.table_name}.#{soft_deletable_column} > 0")
    end

    def restore(id)
      if id.is_a?(Array)
        id.map { |one_id| restore(one_id) }
      else
        only_deleted.find(id).restore!
      end
    end
  end
end
