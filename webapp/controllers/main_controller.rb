class MainController < Sinatra::Base
  configure do
    set :views, File.expand_path('../views', __dir__)
  end

  get '/' do
    erb :index
  end

  get '/run' do
    content_type 'text/event-stream'
    stream :keep_open do |out|
      instructions = params[:instructions]
      message = params[:message]

      assistant = Langchain::Assistant.new(
        instructions: instructions,
        llm: llm,
        tools: [
          InventoryManagement.new,
          ShippingService.new,
          PaymentGateway.new,
          OrderManagement.new,
          CustomerManagement.new,
          EmailService.new,
          DateTimeService.new,
        ],
        add_message_callback: Proc.new { |message|
          out << "data: #{JSON.generate(format_message(message))}\n\n"
        }
      )

      assistant.add_message_and_run content: message, auto_tool_execution: true
      puts("Ricc Debug: #{assistant.pretty_history}")

      out.close
    end
  end

  private


  # "2024-09-15 08:42:32 +0200" => '08:42'
  def hh_mm()
    Time.now.to_s[11,5]
  end

  def format_message(message, add_time: false)
    emoji = format_role(message.role)
    emoji += hh_mm if add_time
    {
      role: message.role,
      # content: "[deb_role=#{message.role}]" + format_content(message).to_s,
      content: format_content(message).to_s,
      emoji: emoji, # format_role(message.role) + hh_mm,
      style: format_style(message),
    }
  end

  def format_content(message)
    message.content.empty? ? message.tool_calls : message.content
  end

  def format_style(message)
    bgColor = ''
    effective_role = message.role
    effective_role = 'array' if message.content.empty?
    case effective_role
      when 'user'
        bgColor = 'bg-blue-100 font-bold' # Added font-bold here
    when 'assistant'
        bgColor = 'bg-red-100'
    when 'model'
        #//bgColor = 'bg-red-100'
        #// Gemini
        bgColor = "bg-gradient-to-r from-blue-500 to-purple-600 font-bold"
    when 'tool', 'function', 'array'
        #//
#        bgColor = 'bg-gray-100 font-mono'
        bgColor = 'bg-gray-100 font-mono text-xs' # or text-xs for even smaller

        #bgColor = 'p-8 rounded-lg text-gray font-mono'
    else # unknown
        bgColor = 'bg-yellow-100'
    end
    #style = "mb-2 p-2 rounded ${bgColor} whitespace-pre-wrap"
    #style
    bgColor
  end

  def format_role(role)
    case role
      # OpenAI: user, assistant, tool
      # Gemini: user, model, function
    when "user"
      "👤"
    when "assistant", "model"
      "🤖"
    when "tool", "function"
      "🛠️"
    else
      "❓ UNKNOWN: '#{role}'"
    end
  end

  def openai_llm
    Langchain::LLM::OpenAI.new(
      api_key: ENV["OPENAI_API_KEY"],
      default_options: { chat_completion_model_name: "gpt-4o-mini" }
    )
  end
  def gemini_llm
    puts("🐞DEBUG🐞 instantiated a new Gemini LLM")
    Langchain::LLM::GoogleGemini.new(
      api_key: ENV["GEMINI_API_KEY"],
      default_options: { chat_completion_model_name: ENV['CHAT_COMPLETION_MODEL_NAME'] }
    )
  end
  def llm
    gemini_llm
  end
end
