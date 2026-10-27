require "timeout"

module Ai
  class InvoiceExtractionService
    def initialize(provider: ProviderRegistry.resolve, timeout_seconds: ENV.fetch("AI_TIMEOUT_SECONDS", "2").to_f)
      @provider = provider
      @timeout_seconds = timeout_seconds
    end

    def extract(filename:)
      raw = @provider.extract_invoice(filename: filename)
      Timeout.timeout(@timeout_seconds) { stringify_keys(raw) }
    rescue StandardError => error
      {
        "status" => "error",
        "message" => error.message,
        "error_class" => error.class.name
      }
    end

    private

    def stringify_keys(raw)
      return {} unless raw.is_a?(Hash)

      raw.each_with_object({}) do |(key, value), memo|
        memo[key.to_s] = value
      end
    end
  end
end
