# frozen_string_literal: true

class CustomerManagement
  extend Langchain::ToolDefinition

  define_function :create_customer, description: "Customer Management Service: Create a new customer with a given name" do
    property :name, type: "string", description: "Customer's name", required: true
    property :email, type: "string", description: "Customer's email address", required: true
  end

  define_function :find_customer, description: "Customer Management Service: Look up a customer by email" do
    property :email, type: "string", description: "Email", required: true
  end
  define_function :find_customer_by_name, description: "Customer Management Service: Look up a customer by name (meaning givenname + surname)" do
    property :name, type: "string", description: "Full Name", required: true
  end

  def initialize
  end

  def create_customer(name:, email:)
    Langchain.logger.info("[ 👤 ] Creating Customer record for #{email}", for: self.class)

    customer = Customer.create(name: name, email: email)

    { success: true, customer_id: customer.id }
  end

  def find_customer(email:)
    Langchain.logger.info("[ 👤 ] Looking up Customer record for #{email}", for: self.class)

    customer = Customer.find(email: email)

    return "Customer not found" if customer.nil?

    customer.to_hash
  end
  def find_customer_by_name(name:)
    Langchain.logger.info("[ 👤 ] Looking up Customer record for #{name}", for: self.class)

    customer = Customer.find(name: name)

    return "Customer not found" if customer.nil?

    customer.to_hash
  end
end
