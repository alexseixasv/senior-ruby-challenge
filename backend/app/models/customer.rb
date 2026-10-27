class Customer < ApplicationRecord
  belongs_to :account
  has_many :invoices, dependent: :restrict_with_exception

  validates :name, :email, presence: true
end
