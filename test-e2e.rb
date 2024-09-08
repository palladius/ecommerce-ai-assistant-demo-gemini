require "bundler/setup"
Bundler.require
require "dotenv/load"

Mail.defaults do
  delivery_method :sendmail
end

Sequel::Model.db = Sequel.sqlite(ENV["DATABASE_NAME"])

# Require all the models
require_relative "./models/product"
require_relative "./models/order"
require_relative "./models/order_item"
require_relative "./models/customer"

# Require all the tools
require_relative "./tools/inventory_management"
require_relative "./tools/payment_gateway"
require_relative "./tools/shipping_service"
require_relative "./tools/order_management"
require_relative "./tools/customer_management"
require_relative "./tools/email_service"
#  Carlessian monkeypatching to make it look nicer..
require_relative "./lib/google_message"
require_relative "./lib/assistant"
require_relative "./lib/database"

require "irb"

require "bundler/setup"
Bundler.require
require "dotenv/load"

Mail.defaults do
  delivery_method :sendmail
end


FEED_SAMPLE_INSTRUCTIONS = ENV.fetch('FEED_SAMPLE_INSTRUCTIONS', 'TruE').to_s.downcase == 'true'
CHAT_COMPLETION_MODEL_NAME= ENV.fetch 'CHAT_COMPLETION_MODEL_NAME'
llm = Langchain::LLM::GoogleGemini.new(
  api_key: ENV["GOOGLE_GEMINI_API_KEY"],
  default_options: { chat_completion_model_name: CHAT_COMPLETION_MODEL_NAME }
)

puts("Gemini model: #{CHAT_COMPLETION_MODEL_NAME}")
puts("FEED_SAMPLE_INSTRUCTIONS: #{FEED_SAMPLE_INSTRUCTIONS}")

exit 42

# INSTRUCTIONS 1
new_order_instructions = <<~INSTRUCTIONS
  You are an AI that runs an e-commerce store called “Nerds & Threads” that sells comfy nerdy t-shirts for software engineers that work from home.

  You have access to the shipping service, inventory service, order management, payment gateway, email service and customer management systems. You are responsible for processing orders.

  FOLLOW THESE EXACT PROCEDURES BELOW:

  New order step by step procedures:
  1. Create customer account if it doesnt exist.
  2. Check inventory for items
  3. Calculate total amount
  4. Charge customer
  5. Create order
  6. Create shipping label. If the address is in Europe, use DHL. If the address is in US, use FedEx.
  7. Send an email notification to customer
INSTRUCTIONS


# Create the assistant
$assistant = Langchain::Assistant.new(
  # Instructions for the assistant that will be passed to Gemini as a "system" message
  instructions: new_order_instructions,
  llm: llm,
  tools: [
    InventoryManagement.new,
    ShippingService.new,
    PaymentGateway.new,
    OrderManagement.new,
    CustomerManagement.new,
    EmailService.new
  ]
)

#assistant.add_message_and_run content: "riccardo.carlesso@gmail.com just purchased 5 t-shirts (Y3048509). His address is 667 Madison Avenue, New York, NY 10065", auto_tool_execution: true
$assistant.msg "Andrei Bondarev (andrei@sourcelabs.io) just purchased 5 t-shirts (Y3048509). His address is 667 Madison Avenue, New York, NY 10065"

$assistant.pretty_history

$assistant.msg "Ok. Riccardo Carlesso (ricc@google.com) just purchased 7 coffee mugs (Z0394853). His address is 667 Madison Avenue, New York, NY 10065. Please confirm total price and how many are left in stock as its very popular today"

$assistant.pretty_history

# give vars to IRB
require "irb"

$DB = Sequel.sqlite(ENV["DATABASE_NAME"])
#$assistant.pretty_history # thread.messages.each{|m| puts m.to_s}
puts("Feel free to interrogate the $DB (eg  $DB[:products].all), or the $assistant (eg $assistant.msg '..')")
IRB.start(__FILE__)
