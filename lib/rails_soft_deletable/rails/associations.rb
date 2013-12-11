require "active_support/concern"

module RailsSoftDeletable
  module Associations
    extend ActiveSupport::Concern

    included do
      alias_method_chain :target_scope, :deleted
    end

    def target_scope_with_deleted
      scope = target_scope_without_deleted

      if scope && options[:with_deleted] && klass.soft_deletable?
        scope = scope.with_deleted
      end

      scope
    end
  end
end
