require "active_record"

module Spec
  module Models
    module SoftDeletableCallbacks
      def self.included(base)
        base.class_eval do
          attr_reader :before_destroy_called
          attr_reader :after_destroy_called

          before_destroy { @before_destroy_called = true }
          after_destroy  { @after_destroy_called = true }

          def reset_callback_flags!
            @before_destroy_called = nil
            @after_destroy_called  = nil
          end
        end
      end
    end
  end
end

class DecimalModel< ActiveRecord::Base
  acts_as_soft_deletable

  include Spec::Models::SoftDeletableCallbacks
end

class IntegerModel < ActiveRecord::Base
  acts_as_soft_deletable

  include Spec::Models::SoftDeletableCallbacks
end
