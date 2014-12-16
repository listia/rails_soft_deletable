require "active_support/concern"

module RailsSoftDeletable
  module Query
    extend ActiveSupport::Concern

    module ClassMethods
      def soft_deletable?
        true
      end

      def with_deleted
        all.tap { |x| x.default_scoped = false }
      end

      def only_deleted
        with_deleted.where("#{self.table_name}.#{soft_deletable_column} > 0")
      end
      alias :deleted :only_deleted

      def restore(id)
        if id.is_a?(Array)
          id.map { |one_id| restore(one_id) }
        else
          only_deleted.find(id).restore!
        end
      end
    end
  end
end
