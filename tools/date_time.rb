class DateTimeService
  extend Langchain::ToolDefinition
  define_function :get_datetime, description: "Tells you what date and time it is." #do
    # property :customer_id, type: "number", description: "Customer ID", required: true
    # property :order_id, type: "number", description: "Order ID", required: true
#  end

  def initialize
  end

  def get_datetime
    Time.now
  end

end
