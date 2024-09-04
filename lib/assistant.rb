

module Langchain
  class Assistant
    def msg(str)
      self.add_message_and_run content: str, auto_tool_execution: true
    end
    def pretty_history
      thread.messages.each_with_index do |m,ix|
        puts("#{ix}|#{m}")
      end
      nil
    end
  end
end
