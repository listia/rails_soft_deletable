require "active_record"

module Spec
  module Support
    class Environment
      DATABASE_FILE = ROOT_PATH.join("tmp/test.sqlite3")
      SCHEMA_FILE   = ROOT_PATH.join("spec/schema.rb")

      def self.setup
        DATABASE_FILE.dirname.mkpath
        DATABASE_FILE.delete if DATABASE_FILE.exist?

        ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: DATABASE_FILE.to_s)

        silence_stream(STDOUT) do
          load(SCHEMA_FILE)
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    Spec::Support::Environment.setup
  end
end
