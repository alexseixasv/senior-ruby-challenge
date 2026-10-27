FactoryBot.define do
  factory :account do
    sequence(:name) { |n| "Account #{n}" }
  end

  factory :customer do
    account
    sequence(:name) { |n| "Customer #{n}" }
    sequence(:email) { |n| "customer-#{n}@example.com" }
    sequence(:external_crm_id) { |n| "crm-#{n}" }
  end

  factory :invoice do
    account
    customer { association :customer, account: account }
    sequence(:invoice_number) { |n| "INV-#{1000 + n}" }
    amount_cents { 18_500 }
    status { "pending" }
    description { "Implementation services" }
  end

  factory :document do
    account
    invoice { association :invoice, account: account }
    sequence(:filename) { |n| "invoice-#{n}.pdf" }
    status { "pending" }
    extracted_data { nil }
  end

  factory :ledger_entry do
    account
    invoice { association :invoice, account: account }
    amount_cents { 18_500 }
    entry_type { "payment_applied" }
    sequence(:external_event_id) { |n| "evt-factory-#{n}" }
  end
end
