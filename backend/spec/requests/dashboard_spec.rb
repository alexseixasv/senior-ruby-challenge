require "rails_helper"

RSpec.describe "dashboard summary", type: :request do
  it "returns invoice counts for the authenticated account" do
    account = create(:account)
    customer = create(:customer, account: account)
    create(:invoice, account: account, customer: customer, status: "pending")
    create(:invoice, account: account, customer: customer, status: "processed")
    create(:invoice, account: account, customer: customer, status: "failed")
    create(:invoice, status: "failed")

    get "/api/dashboard/summary", headers: auth_headers(account)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq(
      "total" => 3,
      "pending" => 1,
      "processing" => 0,
      "processed" => 1,
      "failed" => 1
    )
  end
end
