class Document < ApplicationRecord
  STATUSES = %w[pending processing processed failed].freeze

  belongs_to :account
  belongs_to :invoice
  has_many :extraction_runs, dependent: :destroy

  validates :filename, :status, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :invoice_belongs_to_account

  private

  def invoice_belongs_to_account
    return if invoice.nil? || account_id.nil?
    return if invoice.account_id == account_id

    errors.add(:invoice, "must belong to the same account")
  end
end
