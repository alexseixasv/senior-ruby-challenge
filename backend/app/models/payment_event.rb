class PaymentEvent < ApplicationRecord
  belongs_to :account
  belongs_to :invoice

  validates :provider, :external_event_id, :event_type, presence: true
end
