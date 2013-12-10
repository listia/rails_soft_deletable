require "rails_soft_deletable/association"

module RailsSoftDeletable
  module Associations
    class One < Association
      def build
        unless model.method_defined? "#{target}_with_unscoped"
          model.class_eval <<-RUBY, __FILE__, __LINE__
            def #{target}_with_unscoped(*args)
              association = association(:#{target})
              return nil if association.options[:polymorphic] && association.klass.nil?
              return #{target}_without_unscoped(*args) unless association.klass.soft_deletable?
              association.klass.with_deleted.scoping { #{target}_without_unscoped(*args) }
            end
            alias_method_chain :#{target}, :unscoped
          RUBY
        end

        result
      end
    end
  end
end
