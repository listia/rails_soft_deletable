require "soft_deletable_model_callbacks"

class Park < ActiveRecord::Base
  soft_deletable

  has_many :trees

  has_one :tree, conditions: ["biggest = ?", true]

  include SoftDeletableModelCallbacks
end
