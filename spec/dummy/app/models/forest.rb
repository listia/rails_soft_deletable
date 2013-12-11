require "soft_deletable_model_callbacks"

class Forest< ActiveRecord::Base
  soft_deletable

  include SoftDeletableModelCallbacks
end
