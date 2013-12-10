require "active_support/concern"
require "rails_soft_deletable/associations/many"
require "rails_soft_deletable/associations/one"

module RailsSoftDeletable
  module Associations
    extend ActiveSupport::Concern

    module ClassMethods
      def belongs_to(target, options = {})
        with_deleted = options.delete(:with_deleted)
        result = super(target, options = {})

        with_deleted ? One.new(self, target, result).build : result
      end

      def has_one(target, options = {})
        with_deleted = options.delete(:with_deleted)
        result = super(target, options = {})

        with_deleted ? One.new(self, target, result).build : result
      end

      def has_many(target, options = {})
        with_deleted = options.delete(:with_deleted)
        result = super(target, options = {})

        with_deleted ? Many.new(self, target, result).build : result
      end
    end
  end
end
