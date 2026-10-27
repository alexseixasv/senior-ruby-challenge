class Account < ApplicationRecord
  has_many :customers, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :payment_events, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :ledger_entries, dependent: :destroy
  has_many :extraction_runs, dependent: :destroy

  validates :name, presence: true
end
