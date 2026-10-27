require "rails_helper"

RSpec.describe "invoice API", type: :request do
  let(:account) { create(:account, name: "Northwind Logistics") }
  let(:customer) { create(:customer, account: account, name: "Harbor Freight Co") }

  it "lists invoices for the authenticated account" do
    own = create(:invoice, account: account, customer: customer, invoice_number: "INV-100", amount_cents: 15_000)
    other_account = create(:account)
    create(:invoice, account: other_account, invoice_number: "INV-OTHER")

    get "/api/invoices", headers: auth_headers(account)

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body.fetch("invoices").map { |invoice| invoice.fetch("invoice_number") }).to eq(["INV-100"])
    expect(body.fetch("invoices").first.fetch("customer_name")).to eq("Harbor Freight Co")
    expect(body.fetch("invoices").first.fetch("amount_cents")).to eq(own.amount_cents)
    expect(body.fetch("meta")).to include("page" => 1, "total" => 1)
  end

  it "filters invoices by status" do
    create(:invoice, account: account, customer: customer, status: "failed", invoice_number: "INV-FAILED")
    create(:invoice, account: account, customer: customer, status: "pending", invoice_number: "INV-OPEN")

    get "/api/invoices", params: { status: "failed" }, headers: auth_headers(account)

    numbers = response.parsed_body.fetch("invoices").map { |invoice| invoice.fetch("invoice_number") }
    expect(numbers).to eq(["INV-FAILED"])
  end

  it "shows an invoice that belongs to the authenticated account" do
    invoice = create(:invoice, account: account, customer: customer, description: "March retainer")

    get "/api/invoices/#{invoice.id}", headers: auth_headers(account)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "id" => invoice.id,
      "description" => "March retainer",
      "customer_name" => customer.name,
      "documents" => []
    )
  end

  it "creates an invoice" do
    post "/api/invoices",
         params: {
           customer_id: customer.id,
           invoice_number: "INV-NEW",
           amount_cents: 22_500,
           description: "Onboarding"
         },
         headers: auth_headers(account),
         as: :json

    expect(response).to have_http_status(:created)
    expect(response.parsed_body).to include(
      "invoice_number" => "INV-NEW",
      "amount_cents" => 22_500,
      "status" => "pending",
      "account_id" => account.id
    )
  end

  it "rejects an invalid invoice" do
    post "/api/invoices",
         params: { customer_id: customer.id, invoice_number: "", amount_cents: -5 },
         headers: auth_headers(account),
         as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body.fetch("error")).to eq("validation_failed")
  end

  it "does not attach a customer from another account" do
    outsider = create(:customer)

    post "/api/invoices",
         params: { customer_id: outsider.id, invoice_number: "INV-X", amount_cents: 1000 },
         headers: auth_headers(account),
         as: :json

    expect(response).to have_http_status(:not_found)
  end

  it "updates an invoice description" do
    invoice = create(:invoice, account: account, customer: customer, description: "Old")

    patch "/api/invoices/#{invoice.id}",
          params: { description: "Revised scope" },
          headers: auth_headers(account),
          as: :json

    expect(response).to have_http_status(:ok)
    expect(invoice.reload.description).to eq("Revised scope")
  end

  it "requires a demo account token" do
    get "/api/invoices"

    expect(response).to have_http_status(:unauthorized)
  end
end
