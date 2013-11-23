# encoding: UTF-8

ActiveRecord::Schema.define(version: Time.now.strftime("%Y%m%d%H%M%S")) do
  create_table "decimal_models", force: true do |t|
    t.decimal "deleted_at", default: 0
  end

  create_table "integer_models", force: true do |t|
    t.integer "deleted_at", default: 0
  end
end
