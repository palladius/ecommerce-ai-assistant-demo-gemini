# frozen_string_literal: true

class SerpGoogleFlight
  extend Langchain::ToolDefinition

  define_function :search_flights, description: "Searches for Flights." #do
    # property :customer_id, type: "number", description: "Customer ID", required: true
    # property :order_items, type: "array", description: "List of order items that each contain a 'sku' and 'quantity' properties", required: true do
    #   property :items, type: "object", description: "Order item" do
    #     property :product_sku, type: "string", description: "Product SKU", required: true
    #     property :quantity, type: "number", description: "Quantity of the product", required: true
    #   end
    # end
#  end

  def initialize(serp_api_key:)
    @serp_api_key = serp_api_key
  end



end
