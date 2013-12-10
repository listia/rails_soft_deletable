require "soft_deletable_model_callbacks"

class Window < ActiveRecord::Base
  soft_deletable

  include SoftDeletableModelCallbacks
end
