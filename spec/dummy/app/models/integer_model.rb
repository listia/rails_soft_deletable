require "soft_deletable_model_callbacks"

class IntegerModel < ActiveRecord::Base
  soft_deletable

  include SoftDeletableModelCallbacks
end
