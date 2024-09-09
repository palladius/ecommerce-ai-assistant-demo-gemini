# frozen_string_literal: true

class OrderManagement
  extend Langchain::ToolDefinition

  define_function :create_order, description: "Order Management Service: Create a new order" do
    property :customer_id, type: "number", description: "Customer ID", required: true
    property :order_items, type: "array", description: "List of order items that each contain a 'sku' and 'quantity' properties", required: true do
      property :items, type: "object", description: "Order item" do
        property :product_sku, type: "string", description: "Product SKU", required: true
        property :quantity, type: "number", description: "Quantity of the product", required: true
      end
    end
  end

  define_function :mark_as_refunded, description: "Inventory Management Service: Mark order as refunded" do
    property :order_id, type: "string", description: "Order ID", required: true
  end

  define_function :find_order, description: "Inventory Management Service: Find order by ID" do
    property :order_id, type: "string", description: "Order ID", required: true
  end

  def initialize
  end

  def create_order(customer_id:, order_items: [])
    Langchain.logger.info("[ 📦 ] Creating Order record for customer ID: #{customer_id}", for: self.class)

    return "Order items cannot be empty" if order_items.empty?

    order = Order.create(customer_id: customer_id, created_at: Time.now)

    return "Order not found" if order.nil?

    order_items.each do |item|
      #puts("[ 📦 ] Ricc Debug. ITEM=#{item}")
      #ret = OrderItem.create(order_id: order.id, product_sku: item[:product_sku], quantity: item[:quantity])
      # bug: https://github.com/patterns-ai-core/ecommerce-ai-assistant-demo/issues/5
      either_product_sku = item.fetch(:product_sku, item.fetch('product_sku'))
      either_quantity = item.fetch(:quantity, item.fetch('quantity'))
      ret = OrderItem.create(order_id: order.id, product_sku: either_product_sku, quantity: either_quantity)
      #puts("[ 📦 ] Ricc Debug. OrderItem.create() => #{ret.inspect}")
    end

    { success: true, order_id: order.id }
  end

  def mark_as_refunded(order_id:)
    Langchain.logger.info("[ 📦 ] Refunding order ID: #{order_id}", for: self.class)

    order = Order.find(id: order_id)

    return "Order not found" if order.nil?

    { success: !!order.destroy }
  end

  def find_order(order_id:)
    Langchain.logger.info("[ 📦 ] Looking up Order record for ID: #{order_id}", for: self.class)

    order = Order.find(id: order_id)

    return "Order not found" if order.nil?

    order
      .to_hash
      .merge(
        order_items: order.order_items.map(&:to_hash)
      )
  end
end
