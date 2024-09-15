class DateTimeService
  extend Langchain::ToolDefinition
  define_function :get_datetime, description: "Tells you what date and time it is TODAY.
          When asked about date like today or tomorrow, omit the time info and try to use DayOfWeek, day and month. Use European notation.
          When asked about the time, just answer with HH:MM and omit the day unless explicitly asked." #do
    # property :customer_id, type: "number", description: "Customer ID", required: true
    # property :order_id, type: "number", description: "Order ID", required: true
#  end

  def initialize
  end

  def get_datetime
    Time.now
  end

end
