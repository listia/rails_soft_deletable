require "soft_deletable_model_callbacks"

class DecimalModel< ActiveRecord::Base
  soft_deletable

  include SoftDeletableModelCallbacks
end
