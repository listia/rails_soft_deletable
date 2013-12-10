require "soft_deletable_model_callbacks"

class House < ActiveRecord::Base
  belongs_to :owner, with_deleted: true

  belongs_to :park

  has_many :trees, with_deleted: true

  has_many :windows

  has_one :tree, conditions: ["biggest = ?", true], with_deleted: true

  has_one :window, conditions: ["biggest = ?", true]
end
