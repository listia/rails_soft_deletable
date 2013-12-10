require "rails/railtie"
require "rails_soft_deletable/rails/active_record"
require "rails_soft_deletable/rails/associations"

module RailsSoftDeletable
  class Railtie < Rails::Railtie
    initializer "rails_soft_deletable.initialize" do |app|
      ActiveSupport.on_load(:active_record) do
        include(RailsSoftDeletable::ActiveRecord)
        ::ActiveRecord::Associations::Association.send(:include, RailsSoftDeletable::Associations)
        ::ActiveRecord::Associations::Builder::BelongsTo.valid_options += [:with_deleted]
        ::ActiveRecord::Associations::Builder::HasMany.valid_options += [:with_deleted]
        ::ActiveRecord::Associations::Builder::HasOne.valid_options += [:with_deleted]
      end
    end
  end
end
