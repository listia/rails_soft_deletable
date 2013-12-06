module SoftDeletableModelCallbacks
  def self.included(base)
    base.class_eval do
      attr_reader :before_destroy_called
      attr_reader :around_destroy_called
      attr_reader :after_destroy_called

      attr_reader :before_restore_called
      attr_reader :around_restore_called
      attr_reader :after_restore_called

      before_destroy :call_before_destroy
      around_destroy :call_around_destroy
      after_destroy  :call_after_destroy

      before_restore :call_before_restore
      around_restore :call_around_restore
      after_restore  :call_after_restore

      def call_before_destroy
        @before_destroy_called = true
      end

      def call_around_destroy
        yield
        @around_destroy_called = true
      end

      def call_after_destroy
        @after_destroy_called = true
      end

      def call_before_restore
        @before_restore_called = true
      end

      def call_around_restore
        yield
        @around_restore_called = true
      end

      def call_after_restore
        @after_restore_called = true
      end

      def reset_callback_flags!
        @before_destroy_called = nil
        @around_destroy_called = nil
        @after_destroy_called  = nil

        @before_restore_called = nil
        @around_restore_called = nil
        @after_restore_called  = nil
      end
    end
  end
end
