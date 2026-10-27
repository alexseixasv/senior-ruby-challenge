require "rails_helper"

RSpec.describe "payment webhooks", type: :request do
  let(:invoice) { create(:invoice, amount_cents: 40_000, status: "pending") }

  it "applies a successful payment to the invoice" do
    post "/api/webhooks/payments",
         params: payment_succeeded_payload(invoice, event_id: "evt-baseline-1"),
         headers: webhook_headers,
         as: :json

    expect(response).to have_http_status(:ok)
    expect(invoice.reload.status).to eq("processed")
    expect(invoice.processed_at).to be_present
    expect(LedgerEntry.where(invoice: invoice).sum(:amount_cents)).to eq(40_000)
    expect(PaymentEvent.where(external_event_id: "evt-baseline-1").count).to eq(1)
  end

  it "marks the invoice failed without applying cash" do
    post "/api/webhooks/payments",
         params: {
           id: "evt-failed-1",
           type: "payment.failed",
           provider: "northstar_pay",
           data: { invoice_id: invoice.id }
         },
         headers: webhook_headers,
         as: :json

    expect(response).to have_http_status(:ok)
    expect(invoice.reload.status).to eq("failed")
    expect(LedgerEntry.where(invoice: invoice)).to be_empty
  end

  it "rejects a missing webhook token" do
    post "/api/webhooks/payments",
         params: payment_succeeded_payload(invoice, event_id: "evt-unauth"),
         as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(invoice.reload.status).to eq("pending")
  end

  it "returns not found when the invoice does not exist" do
    post "/api/webhooks/payments",
         params: {
           id: "evt-missing",
           type: "payment.succeeded",
           provider: "northstar_pay",
           data: { invoice_id: 0 }
         },
         headers: webhook_headers,
         as: :json

    expect(response).to have_http_status(:not_found)
  end
end
