require "soft_deletable_model_callbacks"

class Forest< ActiveRecord::Base
  soft_deletable

  has_many :trees, with_deleted: true

  has_one :tree, conditions: ["biggest = ?", true], with_deleted: true

  include SoftDeletableModelCallbacks
end
