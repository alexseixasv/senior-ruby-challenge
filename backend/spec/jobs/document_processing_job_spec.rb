require "rails_helper"

RSpec.describe DocumentProcessingJob do
  it "stores deterministic extraction data from the mock provider" do
    document = create(:document, filename: "invoice-42.pdf", status: "pending")

    described_class.new.perform(document.id)

    document.reload
    expect(document.status).to eq("processed")
    expect(document.extracted_data).to include(
      "invoice_number" => "INV-42",
      "amount_cents" => 25_000,
      "currency" => "USD",
      "vendor_name" => "FlowOps Demo Vendor"
    )
    expect(document.extraction_runs.count).to eq(1)
  end
end
