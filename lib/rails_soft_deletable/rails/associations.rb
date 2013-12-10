require "active_support/concern"

module RailsSoftDeletable
  module Associations
    extend ActiveSupport::Concern

    included do
      def target_scope
        return if options[:polymorphic] && klass.nil?

        if options[:with_deleted] && klass.soft_deletable?
          klass.with_deleted
        else
          klass.scoped
        end
      end
    end
  end
end
