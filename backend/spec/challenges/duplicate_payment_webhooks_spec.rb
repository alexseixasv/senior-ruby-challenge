require "rails_helper"

RSpec.describe "duplicate payment webhooks", type: :request do
  self.use_transactional_tests = false

  include TableCleaner

  before { clear_flowops_tables }
  after { clear_flowops_tables }

  let(:invoice) { create(:invoice, amount_cents: 64_000, status: "pending") }

  it "records a single financial application when the same success event is delivered twice" do
    payload = payment_succeeded_payload(invoice, event_id: "evt-duplicate-1")

    2.times do
      post "/api/webhooks/payments", params: payload, headers: webhook_headers, as: :json
      expect(response).to have_http_status(:ok)
    end

    expect(invoice.reload.status).to eq("processed")
    expect(PaymentEvent.where(provider: "northstar_pay", external_event_id: "evt-duplicate-1").count).to eq(1)
    expect(LedgerEntry.where(external_event_id: "evt-duplicate-1").count).to eq(1)
    expect(LedgerEntry.where(invoice: invoice).sum(:amount_cents)).to eq(invoice.amount_cents)
  end

  it "records a single financial application when the same success event arrives concurrently" do
    payload = payment_succeeded_payload(invoice, event_id: "evt-concurrent-1")
    barrier = ThreadBarrier.new(2)
    WebhookStartBarrier.barrier = barrier
    errors = Queue.new
    results = Queue.new

    threads = Array.new(2) do
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          results << Payments::ApplyWebhook.new.call(payload.deep_dup)
        end
      rescue StandardError => error
        errors << error
      end
    end

    threads.each { |thread| thread.join(5) }
    lingering = threads.select(&:alive?)
    lingering.each(&:kill)
    expect(lingering).to be_empty
    expect(errors.size).to eq(0)
    expect(results.size).to eq(2)
    expect(PaymentEvent.where(external_event_id: "evt-concurrent-1").count).to eq(1)
    expect(LedgerEntry.where(external_event_id: "evt-concurrent-1").sum(:amount_cents)).to eq(invoice.amount_cents)
  ensure
    WebhookStartBarrier.barrier = nil
  end
end

module WebhookStartBarrier
  def call(payload)
    WebhookStartBarrier.barrier&.arrive
    super
  end

  class << self
    attr_accessor :barrier
  end
end

Payments::ApplyWebhook.prepend(WebhookStartBarrier) unless Payments::ApplyWebhook.ancestors.include?(WebhookStartBarrier)
