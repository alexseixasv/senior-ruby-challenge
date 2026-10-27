raise "Seeds reset the development database and are not for other environments" unless Rails.env.development?

ActiveRecord::Base.logger&.level = Logger::INFO

CUSTOMER_NAMES = [
  "Harbor Freight Co",
  "Lumen Clinic",
  "Pine Street Goods",
  "Atlas Field Services",
  "Bluebird Medical",
  "Copper Kettle Foods",
  "Northstar Dental",
  "Willow Grant Makers",
  "Ironwood Transit",
  "Sable Analytics",
  "Juniper Hotels",
  "Redcedar Insurance",
  "Marble Court Law"
].freeze

ACCOUNT_PLANS = [
  { name: "Northwind Logistics", customers: 5, invoices: 120 },
  { name: "Brightline Health", customers: 4, invoices: 100 },
  { name: "Cedar & Co.", customers: 4, invoices: 80 }
].freeze

STATUSES = %w[pending processing processed failed].freeze
BASE_TIME = Time.utc(2026, 1, 5, 15, 0, 0)

ActiveRecord::Base.transaction do
  ExtractionRun.delete_all
  LedgerEntry.delete_all
  PaymentEvent.delete_all
  Document.delete_all
  Invoice.delete_all
  Customer.delete_all
  Account.delete_all

  %w[extraction_runs ledger_entries payment_events documents invoices customers accounts].each do |table|
    ActiveRecord::Base.connection.reset_pk_sequence!(table)
  end

  name_cursor = 0
  sequence = 0

  ACCOUNT_PLANS.each do |plan|
    account = Account.create!(name: plan[:name])
    customers = Array.new(plan[:customers]) do |offset|
      customer = Customer.create!(
        account: account,
        name: CUSTOMER_NAMES.fetch(name_cursor),
        email: "ap.#{account.id}.#{offset + 1}@example.com",
        external_crm_id: "crm-#{account.id}-#{offset + 1}"
      )
      name_cursor += 1
      customer
    end

    plan[:invoices].times do |offset|
      sequence += 1
      customer = customers[offset % customers.length]
      status = STATUSES[sequence % STATUSES.length]
      created_at = BASE_TIME + sequence.minutes
      invoice = Invoice.create!(
        account: account,
        customer: customer,
        invoice_number: format("INV-%d-%04d", account.id, offset + 1),
        amount_cents: 5_000 + ((sequence * 173) % 95_000),
        status: status,
        description: "Services for #{customer.name} - cycle #{offset + 1}",
        processed_at: (status == "processed" ? created_at + 2.hours : nil),
        created_at: created_at,
        updated_at: created_at
      )

      if status == "processed"
        external_event_id = "evt-seed-#{invoice.id}"
        event = PaymentEvent.create!(
          account: account,
          invoice: invoice,
          provider: "northstar_pay",
          external_event_id: external_event_id,
          event_type: "payment.succeeded",
          processed_at: invoice.processed_at,
          payload: {
            "id" => external_event_id,
            "type" => "payment.succeeded",
            "provider" => "northstar_pay",
            "data" => { "invoice_id" => invoice.id, "amount_cents" => invoice.amount_cents }
          }
        )
        LedgerEntry.create!(
          account: account,
          invoice: invoice,
          payment_event: event,
          amount_cents: invoice.amount_cents,
          entry_type: "payment_applied",
          external_event_id: external_event_id,
          created_at: invoice.processed_at,
          updated_at: invoice.processed_at
        )
      end

      next if sequence > 30

      document_status = sequence <= 10 ? "processed" : "pending"
      extracted_data = if document_status == "processed"
                         {
                           "invoice_number" => invoice.invoice_number,
                           "amount_cents" => invoice.amount_cents,
                           "currency" => "USD",
                           "vendor_name" => customer.name
                         }
                       end
      document = Document.create!(
        account: account,
        invoice: invoice,
        filename: "acct#{account.id}-#{invoice.invoice_number}.pdf",
        status: document_status,
        extracted_data: extracted_data,
        created_at: created_at,
        updated_at: created_at
      )
      next unless document_status == "processed"

      ExtractionRun.create!(
        account: account,
        document: document,
        outcome: "completed",
        provider_name: "mock",
        result: extracted_data,
        created_at: created_at,
        updated_at: created_at
      )
    end
  end
end

puts "Seeded #{Account.count} accounts, #{Customer.count} customers, #{Invoice.count} invoices, #{Document.count} documents."
