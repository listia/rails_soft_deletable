require "active_support/concern"

module RailsSoftDeletable
  module Callbacks
    extend ActiveSupport::Concern

    included do
      define_callbacks :restore

      define_singleton_method("before_restore") do |*args, &block|
        set_callback(:restore, :before, *args, &block)
      end

      define_singleton_method("around_restore") do |*args, &block|
        set_callback(:restore, :around, *args, &block)
      end

      define_singleton_method("after_restore") do |*args, &block|
        set_callback(:restore, :after, *args, &block)
      end
    end

    def soft_delete_time
      value = send(soft_deletable_column)

      if value.zero? || value.nil?
        nil
      else
        Time.at(value).in_time_zone
      end
    end

    def destroy(destroy_mode = :soft)
      if destroy_mode == :hard
        super()
      else
        if destroyed?
          delete_or_soft_delete(true)
        else
          run_callbacks(:destroy) { delete_or_soft_delete(true) }
        end
      end
    end

    def delete(delete_mode = :soft)
      if delete_mode == :hard
        super()
      else
        return if new_record?
        delete_or_soft_delete
      end
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
      !value || value != 0
    end

    def persisted?
      @_pretend_persistence || super
    end

    private

    def _prepare_for_hard_delete(&block)
      @_pretend_persistence = true
      self.class.unscoped(&block)
    ensure
      @_pretend_persistence = false
    end

    def delete_or_soft_delete(with_transaction = false)
      if destroyed?
        _prepare_for_hard_delete { delete(:hard) }
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

      current_time = ("%0.6f" % current_time_from_proper_timezone).to_f
      changes = {}

      changes[soft_deletable_column.to_s] = write_attribute(soft_deletable_column.to_s, current_time)

      changes[self.class.locking_column] = increment_lock if locking_enabled?

      @changed_attributes.except!(*changes.keys)
      primary_key = self.class.primary_key
      self.class.unscoped.where(primary_key => self[primary_key]).update_all(changes) == 1
    end
  end
end
