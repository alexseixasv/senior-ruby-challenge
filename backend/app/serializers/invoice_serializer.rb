class InvoiceSerializer
  def initialize(invoice, include_details: false)
    @invoice = invoice
    @include_details = include_details
  end

  def as_json
    payload = {
      id: @invoice.id,
      account_id: @invoice.account_id,
      customer_id: @invoice.customer_id,
      customer_name: @invoice.customer.name,
      invoice_number: @invoice.invoice_number,
      amount_cents: @invoice.amount_cents,
      status: @invoice.status,
      description: @invoice.description,
      processed_at: @invoice.processed_at&.iso8601,
      created_at: @invoice.created_at&.iso8601,
      updated_at: @invoice.updated_at&.iso8601
    }

    return payload unless @include_details

    payload.merge(
      applied_cents: @invoice.ledger_entries.sum(:amount_cents),
      documents: @invoice.documents.order(:id).map { |document| DocumentSerializer.new(document).as_json }
    )
  end
end
