require "rails_helper"

RSpec.describe "invoice listing queries", type: :request do
  it "loads a page of invoices and their customers in a bounded number of queries" do
    account = create(:account)
    8.times do |index|
      customer = create(:customer, account: account, name: "Customer #{index}")
      create(:invoice, account: account, customer: customer, invoice_number: "INV-Q-#{index}")
    end

    queries = []
    ActiveRecord::Base.uncached do
      queries = QueryCounter.capture do
        get "/api/invoices", params: { per_page: 50 }, headers: auth_headers(account)
      end
    end

    names = response.parsed_body.fetch("invoices").map { |invoice| invoice.fetch("customer_name") }
    expect(names).to all(be_present)
    expect(queries.length).to be <= 5, "queries:\n#{queries.join("\n")}"
  end
end
