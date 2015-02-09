module SoftDeletableModelCallbacks
  def self.included(base)
    base.class_eval do
      attr_reader :callback_order

      attr_reader :before_destroy_called
      attr_reader :around_destroy_called
      attr_reader :after_destroy_called

      attr_reader :before_restore_called
      attr_reader :around_restore_called
      attr_reader :after_restore_called

      attr_reader :after_commit_called

      before_destroy :call_before_destroy
      around_destroy :call_around_destroy
      after_destroy  :call_after_destroy

      before_restore :call_before_restore
      around_restore :call_around_restore
      after_restore  :call_after_restore

      after_commit :call_after_commit, on: :destroy

      def call_before_destroy
        @before_destroy_called = next_callback_order
      end

      def call_around_destroy
        @around_destroy_called = next_callback_order
        yield
      end

      def call_after_destroy
        @after_destroy_called = next_callback_order
      end

      def call_before_restore
        @before_restore_called = next_callback_order
      end

      def call_around_restore
        @around_restore_called = next_callback_order
        yield
      end

      def call_after_restore
        @after_restore_called = next_callback_order
      end

      def call_after_commit
        @after_commit_called = next_callback_order
      end

      def reset_callback_flags!
        @callback_order = 0

        @before_destroy_called = nil
        @around_destroy_called = nil
        @after_destroy_called  = nil

        @before_restore_called = nil
        @around_restore_called = nil
        @after_restore_called  = nil

        @after_commit_called = nil
      end

      def next_callback_order
        @callback_order ||= 0
        @callback_order += 1
      end
    end
  end
end
