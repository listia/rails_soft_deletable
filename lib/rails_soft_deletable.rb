require "rails_soft_deletable/version"

module RailsSoftDeletable
  def self.included(base)
    base.extend Query
    base.extend Callbacks
  end

  module Query
    def soft_deletable?
      true
    end

    def with_deleted
      scoped.tap { |x| x.default_scoped = false }
    end

    def only_deleted
      with_deleted.where("#{self.table_name}.#{soft_deletable_column} > 0")
    end
    alias :deleted :only_deleted

    def restore(id)
      if id.is_a?(Array)
        id.map { |one_id| restore(one_id) }
      else
        only_deleted.find(id).restore!
      end
    end
  end

  module Callbacks
    def self.extended(base)
      base.define_callbacks :restore

      base.define_singleton_method("before_restore") do |*args, &block|
        set_callback(:restore, :before, *args, &block)
      end

      base.define_singleton_method("around_restore") do |*args, &block|
        set_callback(:restore, :around, *args, &block)
      end

      base.define_singleton_method("after_restore") do |*args, &block|
        set_callback(:restore, :after, *args, &block)
      end
    end
  end

  def destroy
    if destroyed?
      delete_or_soft_delete(true)
    else
      run_callbacks(:destroy) { delete_or_soft_delete(true) }
    end
  end

  def delete
    return if new_record?
    delete_or_soft_delete
  end

  def restore!
    run_callbacks(:restore) do
      # XXX: Rails >3.2.11 fixes an issue with update_column:
      # https://github.com/rails/rails/commit/a3c3cfdd0ebba26bb9dfc0bfd4e23a5f336730c0
      # Since we're on 3.2.11, we cannot use update_column.
      #   update_column(soft_deletable_column, 0)

      name = soft_deletable_column.to_s
      updated_count = self.class.unscoped.update_all({ name => 0 }, self.class.primary_key => id)
      raw_write_attribute(name, 0)

      updated_count == 1
    end
  end
  alias :restore :restore!

  def destroyed?
    value = send(soft_deletable_column)
    value && value != 0
  end
  alias :deleted? :destroyed?

  private

  def delete_or_soft_delete(with_transaction = false)
    if destroyed?
      self.class.unscoped { hard_delete! }
    else
      touch_soft_deletable_column(with_transaction)
    end
  end

  def touch_soft_deletable_column(with_transaction=false)
    if with_transaction
      with_transaction_returning_status { touch_column }
    else
      touch_column
    end
  end

  def touch_column
    raise ActiveRecordError, "can not touch on a new record object" unless persisted?

    current_time = current_time_from_proper_timezone.to_i
    changes = {}

    changes[soft_deletable_column.to_s] = write_attribute(soft_deletable_column.to_s, current_time)

    changes[self.class.locking_column] = increment_lock if locking_enabled?

    @changed_attributes.except!(*changes.keys)
    primary_key = self.class.primary_key
    self.class.unscoped.where(primary_key => self[primary_key]).update_all(changes) == 1
  end
end

class ActiveRecord::Base
  def self.acts_as_soft_deletable(options={})
    alias :hard_destroy! :destroy
    alias :hard_delete! :delete
    include RailsSoftDeletable
    class_attribute :soft_deletable_column

    self.soft_deletable_column = options[:column] || :deleted_at
    default_scope { where(self.quoted_table_name + ".#{soft_deletable_column} = 0") }
  end

  def self.soft_deletable?
    false
  end

  def soft_deletable?
    self.class.soft_deletable?
  end

  # Override the persisted method to allow for the paranoia gem.
  # If a paranoid record is selected, then we only want to check
  # if it's a new record, not if it is "destroyed".
  def persisted?
    soft_deletable? ? !new_record? : super
  end

  private

  def soft_deletable_column
    self.class.soft_deletable_column
  end
end
