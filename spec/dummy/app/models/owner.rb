require "soft_deletable_model_callbacks"

class Owner< ActiveRecord::Base
  soft_deletable

  include SoftDeletableModelCallbacks
end
