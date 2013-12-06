require "rails/railtie"
require "rails_soft_deletable/rails/active_record"

module RailsSoftDeletable
  class Railtie < Rails::Railtie
    initializer "rails_soft_deletable.initialize" do |app|
      ActiveSupport.on_load(:active_record) do
        include(RailsSoftDeletable::ActiveRecord)
      end
    end
  end
end
