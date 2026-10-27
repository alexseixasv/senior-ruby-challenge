require "rails_helper"

RSpec.describe "document API", type: :request do
  let(:account) { create(:account) }
  let(:invoice) { create(:invoice, account: account) }
  let(:document) { create(:document, account: account, invoice: invoice, filename: "invoice-15.pdf") }

  it "returns a document for the authenticated account" do
    get "/api/documents/#{document.id}", headers: auth_headers(account)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "id" => document.id,
      "filename" => "invoice-15.pdf",
      "status" => "pending"
    )
  end

  it "enqueues document processing" do
    expect do
      post "/api/documents/#{document.id}/process", headers: auth_headers(account)
    end.to change { DocumentProcessingJob.jobs.size }.by(1)

    expect(response).to have_http_status(:accepted)
    expect(document.reload.status).to eq("pending")
  end
end
