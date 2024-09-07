# E-commerce AI Assistant

Self: https://github.com/palladius/ecommerce-ai-assistant-demo-gemini/

Original from Andrei: https://github.com/patterns-ai-core/ecommerce-ai-assistant-demo/

An e-commerce AI assistant built with [Langchain.rb](https://github.com/andreibondarev/langchainrb) and Gemini. This demo articulates the idea that business logic will now also live in prompts. A lot of modern software development is stringing services (classes and APIs) together. This demo illustrate how AI can assist in executing business logic and orchestrating calls to various services.

Original repo by Andrei: https://github.com/patterns-ai-core/ecommerce-ai-assistant-demo
Original Video tutorial: https://www.loom.com/share/83aa4fd8dccb492aad4ca95da40ed0b2

### Diagram
<img src="https://github.com/patterns-ai-core/ecommerce-ai-assistant-demo/assets/541665/e17032a5-336d-44e7-b070-3695e69003f6" height="400" />

### Installation
1. `git clone https://github.com/palladius/ecommerce-ai-assistant-demo-gemini/` (and `cd` there)
2. `bundle install`
3. `cp .env.example .env` and fill it out with your values.
4. Run `sendmail` in a separate tab.

### Running automatically

1. Run `setup_db.rb` to set up the database, if needed:
```bash
make db
```

2A. Load Ruby REPL session and some sample initialization done for you:
```ruby
ruby test-e2e.rb
```

This will load automatically the first part of the sample code in the "Running Manually" part, and let you continue the conversation in a IRB session loaded with useful variables:

* `$assistant` (**Langchain::Assistant**). Sample invocations: `$assistant.pretty_history` or `$assistant.msg 'Customer Jane Doe wants to buy 5 tshirts of SKU B9384509 please. Can she?'`
* `$DB` with Sequel **DB**. Sample invocations: `$DB[:products].all` or `db_dump`

### Running manually

1. Run `setup_db.rb` to set up the database, if needed:
```bash
make db
```


1. Load Ruby REPL session with everything loaded:
```ruby
ruby main.rb
```

1. Paste it the following code:
```ruby
llm = Langchain::LLM::GoogleGemini.new(
  api_key: ENV["GOOGLE_GEMINI_API_KEY"],
  default_options: { chat_completion_model_name: "gemini-1.5-flash" }
)

# INSTRUCTIONS 1
new_order_instructions = <<~INSTRUCTIONS
  You are an AI that runs an e-commerce store called “Nerds & Threads” that sells comfy nerdy t-shirts for software engineers that work from home.

  You have access to the shipping service, inventory service, order management, payment gateway, email service and customer management systems. You are responsible for processing orders.

  FOLLOW THESE EXACT PROCEDURES BELOW:

  New order step by step procedures:
  1. Create customer account if it doesn't exist
  2. Check inventory for items
  3. Calculate total amount
  4. Charge customer
  5. Create order
  6. Create shipping label. If the address is in Europe, use DHL. If the address is in US, use FedEx.
  7. Send an email notification to customer
INSTRUCTIONS

# INSTRUCTIONS 2
return_order_instructions = <<~INSTRUCTIONS
  You are an AI that runs an e-commerce store called “Nerds & Threads” that sells comfy nerdy t-shirts for software engineers that work from home.

  You have access to the shipping service, inventory service, order management, payment gateway, email service and customer management systems. You are responsible for handling returns.

  FOLLOW THESE EXACT PROCEDURES BELOW:

  Return step by step procedures:
  1. Lookup the order
  2. Calculate total amount
  3. Refund the payment
  4. Mark the order as refunded
INSTRUCTIONS

# Create the assistant
assistant = Langchain::Assistant.new(
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

# REQUESTS:

# Submit an individual order:
assistant.add_message_and_run content: "Andrei Bondarev (andrei@sourcelabs.io) just purchased 5 t-shirts (Y3048509). His address is 667 Madison Avenue, New York, NY 10065", auto_tool_execution: true

# Clear the thread
assistant.clear_thread!
# Reset the instructions
assistant.instructions = new_order_instructions

# Submit another order:
assistant.add_message_and_run content: """
New Order
Customer: Stephen Margheim (stephen.margheim@gmail.com)
Items: B9384509 x 2, X3048509 x 1
3 Leuthingerweg, Spandau, Berlin, 13591, Deutschland
""", auto_tool_execution: true

# Clear the thread
assistant.clear_thread!
# Set the new instructions
assistant.instructions = return_order_instructions

# Process a return:
assistant.add_message_and_run content: "stephen.margheim@gmail.com is returning order ID: 2", auto_tool_execution: true

# Clear the thread
assistant.clear_thread!
# Set the new instructions
assistant.instructions = return_order_instructions

# Updating inventory:
assistant.add_message_and_run content: """
INVENTORY UPDATE:
B9384509: 100 - $30
X3048509: 200 - $25
A3045809: 10 - $35
""", auto_tool_execution: true
```

## Sample invocation

```
0|🧑 [user] 💬 Andrei Bondarev (andrei@sourcelabs.io) just purchased 5 t-shirts (Y3048509). His address is 667 Madison Avenue, New York, NY 10065
1|🤖 [model] 🛠️ [1/1] 🛠️  {"name"=>"customer_management__find_customer", "args"=>{"email"=>"andrei@sourcelabs.io"}}
2|🔢 [func] 🛠️  customer_management__find_customer => {:id=>2, :name=>"Andrei Bondarev Jr", :email=>"andrei@sourcelabs.io"}
3|🤖 [model] 🛠️ [1/1] 🛠️  {"name"=>"inventory_management__find_product", "args"=>{"sku"=>"Y3048509"}}
4|🔢 [func] 🛠️  inventory_management__find_product => {:sku=>"Y3048509", :price=>24.99, :quantity=>0}
5|🤖 [modl] 💬 We are currently out of stock for that t-shirt.  We can notify you when it is back in stock. Would you like to be added to the waitlist?
6|🧑 [user] 💬 Ok. Riccardo Carlesso (ricc@google.com) just purchased 7 coffee mugs (Z0394853). His address is 667 Madison Avenue, New York, NY 10065. Please confirm total price and how many are left in stock as its very popular today
7|🤖 [model] 🛠️ [1/1] 🛠️  {"name"=>"customer_management__find_customer", "args"=>{"email"=>"ricc@google.com"}}
8|🔢 [func] 🛠️  customer_management__find_customer => {:id=>3, :name=>"Riccardo Carlesso", :email=>"ricc@google.com"}
9|🤖 [model] 🛠️ [1/1] 🛠️  {"name"=>"inventory_management__find_product", "args"=>{"sku"=>"Z0394853"}}
10|🔢 [func] 🛠️  inventory_management__find_product => {:sku=>"Z0394853", :price=>22.99, :quantity=>20}
11|🤖 [modl] 💬 The total price for 7 coffee mugs is $160.93. We have 20 left in stock.
Feel free to interrogate the $DB (eg  $DB[:products].all), or the $assistant (eg $assistant.msg '..')
```

### Known issues

* Running the asistant with Gemini latest model (`gemini-1.5-pro`) yields best results but tends to get throttled if you call it multiple times in a second, and usually results in HTTP 500s after 3-4 calls. We suggest to use Gemini 1.5 Flash (`gemini-1.5-flash`) for this exercise.
