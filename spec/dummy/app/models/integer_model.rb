require "soft_deletable_model_callbacks"

class IntegerModel < ActiveRecord::Base
  soft_deletable

  include SoftDeletableModelCallbacks

  has_many :decimal_models
  has_many :decimal_models_with_deleted, -> { unscope where: :deleted_at }, class_name: "DecimalModel"
end
