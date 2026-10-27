module Ai
  class ProviderRegistry
    def self.resolve
      if ENV["AI_PROVIDER"] == "openai"
        OpenaiCompatibleProvider.new
      else
        MockProvider.new
      end
    end

    def self.current_name
      ENV["AI_PROVIDER"] == "openai" ? "openai_compatible" : "mock"
    end
  end
end
