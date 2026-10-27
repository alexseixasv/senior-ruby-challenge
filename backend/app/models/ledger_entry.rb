class LedgerEntry < ApplicationRecord
  ENTRY_TYPES = %w[payment_applied].freeze

  belongs_to :account
  belongs_to :invoice
  belongs_to :payment_event, optional: true

  validates :entry_type, inclusion: { in: ENTRY_TYPES }
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :external_event_id, presence: true
end
