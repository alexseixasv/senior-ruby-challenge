require "rails_helper"

RSpec.describe "AI extraction failure handling" do
  def pending_document(filename)
    create(:document, filename: filename, status: "pending", extracted_data: nil)
  end

  it "keeps a timed out extraction retryable and does not store a payload" do
    document = pending_document("scenario-timeout.pdf")

    expect { DocumentProcessingJob.new.perform(document.id) }.to raise_error(Ai::RetryableError)

    document.reload
    expect(document.status).to eq("pending")
    expect(document.extracted_data).to be_nil
    expect(document.extraction_runs).to be_empty
  end

  it "keeps a rate-limited extraction retryable and does not store a payload" do
    document = pending_document("scenario-rate-limit.pdf")

    expect { DocumentProcessingJob.new.perform(document.id) }.to raise_error(Ai::RetryableError)

    document.reload
    expect(document.status).to eq("pending")
    expect(document.extracted_data).to be_nil
    expect(document.extraction_runs).to be_empty
  end

  it "fails a document when the provider returns an unexpected structure" do
    document = pending_document("scenario-invalid.pdf")

    expect { DocumentProcessingJob.new.perform(document.id) }.not_to raise_error

    document.reload
    expect(document.status).to eq("failed")
    expect(document.extracted_data).to be_nil
    expect(document.extraction_runs).to be_empty
  end
end
