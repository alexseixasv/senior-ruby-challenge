class Invoice < ApplicationRecord
  STATUSES = %w[pending processing processed failed].freeze

  belongs_to :account
  belongs_to :customer
  has_many :payment_events, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :ledger_entries, dependent: :destroy

  validates :invoice_number, :status, presence: true
  validates :amount_cents, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :status, inclusion: { in: STATUSES }
  validates :invoice_number, uniqueness: { scope: :account_id }
  validate :customer_belongs_to_account

  private

  def customer_belongs_to_account
    return if customer.nil? || account_id.nil?
    return if customer.account_id == account_id

    errors.add(:customer, "must belong to the same account")
  end
end
