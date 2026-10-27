require "rails_helper"

RSpec.describe Ai::InvoiceExtractionService do
  it "returns structured invoice data without an external API key" do
    result = described_class.new.extract(filename: "invoice-42.pdf")

    expect(result).to include(
      "invoice_number" => "INV-42",
      "amount_cents" => 25_000,
      "currency" => "USD",
      "vendor_name" => "FlowOps Demo Vendor"
    )
    expect(ENV["OPENAI_API_KEY"].to_s).to eq("")
  end
end
