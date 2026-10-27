class DocumentSerializer
  def initialize(document)
    @document = document
  end

  def as_json
    {
      id: @document.id,
      account_id: @document.account_id,
      invoice_id: @document.invoice_id,
      filename: @document.filename,
      status: @document.status,
      extracted_data: @document.extracted_data,
      created_at: @document.created_at&.iso8601,
      updated_at: @document.updated_at&.iso8601
    }
  end
end
