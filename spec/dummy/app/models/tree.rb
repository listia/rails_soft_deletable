require "soft_deletable_model_callbacks"

class Tree < ActiveRecord::Base
  soft_deletable

  belongs_to :forest, with_deleted: true

  belongs_to :park

  include SoftDeletableModelCallbacks
end
