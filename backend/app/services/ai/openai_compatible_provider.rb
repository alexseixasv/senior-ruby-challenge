require "json"
require "net/http"
require "uri"

module Ai
  class OpenaiCompatibleProvider
    def initialize(
      api_key: ENV["OPENAI_API_KEY"],
      base_url: ENV.fetch("OPENAI_BASE_URL", "https://api.openai.com/v1"),
      model: ENV.fetch("OPENAI_MODEL", "gpt-4o-mini"),
      timeout_seconds: ENV.fetch("AI_TIMEOUT_SECONDS", "2").to_f
    )
      @api_key = api_key
      @base_url = base_url
      @model = model
      @timeout_seconds = timeout_seconds
    end

    def extract_invoice(filename:, content: nil)
      raise ConfigurationError, "OPENAI_API_KEY is not configured" if @api_key.to_s.empty?

      uri = URI.parse("#{@base_url.chomp("/")}/chat/completions")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = @timeout_seconds
      http.read_timeout = @timeout_seconds

      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{@api_key}"
      request["Content-Type"] = "application/json"
      request.body = JSON.generate(request_body(filename, content))

      handle_response(http.request(request))
    end

    private

    def request_body(filename, content)
      {
        model: @model,
        temperature: 0,
        response_format: { type: "json_object" },
        messages: [
          {
            role: "system",
            content: "Extract an invoice as JSON with keys invoice_number, amount_cents, currency, and vendor_name."
          },
          {
            role: "user",
            content: "Filename: #{filename}\n\n#{content}"
          }
        ]
      }
    end

    def handle_response(response)
      case response.code.to_i
      when 200
        parsed = JSON.parse(response.body)
        content = parsed.dig("choices", 0, "message", "content")
        JSON.parse(content)
      when 429
        raise RateLimitError, "provider rate limit"
      when 408, 500, 502, 503, 504
        raise UnavailableError, "provider unavailable (HTTP #{response.code})"
      else
        raise InvalidResponseError, "provider returned HTTP #{response.code}"
      end
    rescue JSON::ParserError
      raise InvalidResponseError, "provider returned invalid JSON"
    end
  end
end
