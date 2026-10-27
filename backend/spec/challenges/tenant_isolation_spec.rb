require "rails_helper"

RSpec.describe "tenant isolation", type: :request do
  it "does not reveal an invoice owned by another account" do
    account = create(:account, name: "Northwind Logistics")
    other = create(:account, name: "Brightline Health")
    secret = create(:invoice, account: other, invoice_number: "INV-SECRET", description: "Confidential retainer")

    get "/api/invoices/#{secret.id}", headers: auth_headers(account)

    expect(response).to have_http_status(:not_found)
    expect(response.body).not_to include("INV-SECRET")
    expect(response.body).not_to include("Confidential retainer")
  end
end
