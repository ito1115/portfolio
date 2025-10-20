class PurchaseMedium < ApplicationRecord
  has_many :readings, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :category, inclusion: { in: %w[physical digital other] }, allow_nil: true
end
