class ExtractionRun < ApplicationRecord
  belongs_to :account
  belongs_to :document

  validates :outcome, :provider_name, presence: true
end
