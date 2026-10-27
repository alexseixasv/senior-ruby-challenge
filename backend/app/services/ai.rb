module Ai
  class Error < StandardError; end

  class RetryableError < Error; end

  class ProviderTimeoutError < RetryableError; end
  class RateLimitError < RetryableError; end
  class UnavailableError < RetryableError; end

  class InvalidResponseError < Error; end
  class ConfigurationError < Error; end
end
