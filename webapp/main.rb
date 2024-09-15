require "bundler/setup"
Bundler.require
require "dotenv/load"

Mail.defaults do
  delivery_method :sendmail
end

Sequel::Model.db = Sequel.sqlite(ENV["DATABASE_NAME"])

# Require all the models
Dir["../models/*.rb"].each { |file| require_relative file }
# Require all the tools
Dir["../tools/*.rb"].each { |file| require_relative file }

require_relative "./controllers/main_controller"
