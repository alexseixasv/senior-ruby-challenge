module Payments
  class ApplyWebhook
    SUPPORTED_TYPES = %w[payment.succeeded payment.failed].freeze

    def call(payload)
      payload = payload.deep_stringify_keys
      event_type = payload.fetch("type")
      raise ArgumentError, "unsupported event" unless SUPPORTED_TYPES.include?(event_type)

      invoice = Invoice.find(payload.fetch("data").fetch("invoice_id"))
      external_event_id = payload.fetch("id")
      provider = payload.fetch("provider")

      event = PaymentEvent.create!(
        account_id: invoice.account_id,
        invoice: invoice,
        provider: provider,
        external_event_id: external_event_id,
        event_type: event_type,
        payload: payload,
        processed_at: Time.current
      )

      entry = nil
      if event_type == "payment.succeeded"
        entry = LedgerEntry.create!(
          account_id: invoice.account_id,
          invoice: invoice,
          payment_event: event,
          amount_cents: invoice.amount_cents,
          entry_type: "payment_applied",
          external_event_id: external_event_id
        )
        invoice.update!(status: "processed", processed_at: invoice.processed_at || Time.current)
      else
        invoice.update!(status: "failed")
      end

      {
        invoice_id: invoice.id,
        status: invoice.reload.status,
        ledger_entry_id: entry&.id,
        external_event_id: external_event_id
      }
    end
  end
end
