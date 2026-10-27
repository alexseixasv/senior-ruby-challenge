module Api
  module Webhooks
    class PaymentsController < ApplicationController
      def create
        unless webhook_authorized?
          render json: { error: "unauthorized" }, status: :unauthorized
          return
        end

        payload = JSON.parse(request.raw_post)
        result = Payments::ApplyWebhook.new.call(payload)
        render json: result
      rescue JSON::ParserError, KeyError, ArgumentError
        render json: { error: "invalid_payload" }, status: :bad_request
      end

      private

      def webhook_authorized?
        expected = ENV.fetch("PAYMENTS_WEBHOOK_TOKEN")
        provided = request.headers["X-Webhook-Token"].to_s
        return false unless provided.bytesize == expected.bytesize && !expected.empty?

        ActiveSupport::SecurityUtils.secure_compare(provided, expected)
      end
    end
  end
end
