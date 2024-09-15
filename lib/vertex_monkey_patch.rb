# module Langchain::LLM
#   #
#   # Wrapper around the Google Vertex AI APIs: https://cloud.google.com/vertex-ai
#   #
#   # Gem requirements:
#   #     gem "googleauth"
#   #
#   # Usage:
#   #     llm = Langchain::LLM::GoogleVertexAI.new(project_id: ENV["GOOGLE_VERTEX_AI_PROJECT_ID"], region: "us-central1")
#   #
#   class GoogleVertexAI < Base


#     # Generate a chat completion for given messages
#     #
#     # @param messages [Array<Hash>] Input messages
#     # @param model [String] The model that will complete your prompt
#     # @param tools [Array<Hash>] The tools to use
#     # @param tool_choice [String] The tool choice to use
#     # @param system [String] The system instruction to use
#     # @return [Langchain::LLM::GoogleGeminiResponse] Response object
#     def chat(params = {})
#       params[:system] = {parts: [{text: params[:system]}]} if params[:system]
#       params[:tools] = {function_declarations: params[:tools]} if params[:tools]
#       # This throws an error when tool_choice is passed
#       puts('♊️ Gemini VertexAI is monkeypatched by Riccardo! 🐒🔧')
#       #params[:tool_choice] = {function_calling_config: {mode: params[:tool_choice].upcase}} if params[:tool_choice]

#       raise ArgumentError.new("messages argument is required") if Array(params[:messages]).empty?

#       parameters = chat_parameters.to_params(params)
#       parameters[:generation_config] = {temperature: parameters.delete(:temperature)} if parameters[:temperature]

#       uri = URI("#{url}#{parameters[:model]}:generateContent")

#       request = Net::HTTP::Post.new(uri)
#       request.content_type = "application/json"
#       request["Authorization"] = "Bearer #{@authorizer.fetch_access_token!["access_token"]}"
#       request.body = parameters.to_json

#       response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
#         http.request(request)
#       end

#       parsed_response = JSON.parse(response.body)

#       wrapped_response = Langchain::LLM::GoogleGeminiResponse.new(parsed_response, model: parameters[:model])

#       if wrapped_response.chat_completion || Array(wrapped_response.tool_calls).any?
#         wrapped_response
#       else
#         raise StandardError.new(response.body)
#       end
#     end
#   end
# end
