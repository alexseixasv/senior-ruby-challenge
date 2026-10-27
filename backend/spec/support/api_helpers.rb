module ApiHelpers
  def auth_headers(account)
    { "Authorization" => "Bearer demo-account-#{account.id}" }
  end

  def webhook_headers
    { "X-Webhook-Token" => ENV.fetch("PAYMENTS_WEBHOOK_TOKEN") }
  end

  def payment_succeeded_payload(invoice, event_id:)
    {
      "id" => event_id,
      "type" => "payment.succeeded",
      "provider" => "northstar_pay",
      "data" => {
        "invoice_id" => invoice.id,
        "amount_cents" => invoice.amount_cents
      }
    }
  end
end
