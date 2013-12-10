require "rails/railtie"
require "rails_soft_deletable/rails/active_record"
require "rails_soft_deletable/associations"

module RailsSoftDeletable
  class Railtie < Rails::Railtie
    initializer "rails_soft_deletable.initialize" do |app|
      ActiveSupport.on_load(:active_record) do
        include(RailsSoftDeletable::ActiveRecord)
        include(RailsSoftDeletable::Associations)
      end
    end
  end
end
