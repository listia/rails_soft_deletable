RSpec.configure do |config|
  config.before(:suite) do
    silence_stream(STDOUT) do
      load("#{Rails.root}/db/schema.rb")
    end
  end
end
