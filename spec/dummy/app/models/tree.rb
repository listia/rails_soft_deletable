require "soft_deletable_model_callbacks"

class Tree < ActiveRecord::Base
  soft_deletable

  include SoftDeletableModelCallbacks
end
