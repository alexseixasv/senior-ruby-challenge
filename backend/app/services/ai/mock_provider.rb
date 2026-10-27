module Ai
  class MockProvider
    def extract_invoice(filename:)
      name = filename.to_s
      return simulated_result(name) if name.include?("scenario-")

      number = name[/\d+/] || "1000"
      {
        "invoice_number" => "INV-#{number}",
        "amount_cents" => 25_000,
        "currency" => "USD",
        "vendor_name" => "FlowOps Demo Vendor"
      }
    end

    private

    def simulated_result(filename)
      case filename
      when /scenario-timeout/
        raise ProviderTimeoutError, "mock provider timed out"
      when /scenario-rate-limit/
        raise RateLimitError, "mock provider rate limit"
      when /scenario-unavailable/
        raise UnavailableError, "mock provider unavailable"
      when /scenario-invalid/
        { "vendor" => "unparsed" }
      else
        raise ArgumentError, "unknown extraction scenario"
      end
    end
  end
end
