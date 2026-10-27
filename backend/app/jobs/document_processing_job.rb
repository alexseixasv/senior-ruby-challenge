class DocumentProcessingJob
  include Sidekiq::Job

  sidekiq_options retry: 5, queue: "default"

  def perform(document_id)
    document = Document.find(document_id)
    return if already_processed?(document)

    document.update!(status: "processing")
    payload = Ai::InvoiceExtractionService.new.extract(filename: document.filename)

    ExtractionRun.create!(
      account_id: document.account_id,
      document: document,
      outcome: "completed",
      provider_name: Ai::ProviderRegistry.current_name,
      result: payload
    )

    document.update!(status: "processed", extracted_data: payload)
  end

  def already_processed?(document)
    document.status == "processed"
  end
end
