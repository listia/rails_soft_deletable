require "rails_soft_deletable/query"
require "rails_soft_deletable/callbacks"

module RailsSoftDeletable
  module ActiveRecord
    extend ActiveSupport::Concern

    def soft_deletable?
      self.class.soft_deletable?
    end

    private

    def soft_deletable_column
      self.class.soft_deletable_column
    end

    module ClassMethods
      def soft_deletable(options = {})
        include RailsSoftDeletable::Query
        include RailsSoftDeletable::Callbacks

        class_attribute :soft_deletable_column

        self.soft_deletable_column = options[:column] || :deleted_at
        default_scope { where(soft_deletable_column => 0) }
      end

      def soft_deletable?
        false
      end
    end
  end
end
