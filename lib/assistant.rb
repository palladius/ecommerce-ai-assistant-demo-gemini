

module Langchain
  class Assistant
    # Send message, executes it and prints the history.
    def msg(str)
      self.add_message_and_run content: str, auto_tool_execution: true
      puts(pretty_history)
      db_dump
      nil
    end
    def pretty_history
      thread.messages.each_with_index do |m,ix|
        puts("#{ix}|#{m}")
      end
      nil
    end
  end
end
