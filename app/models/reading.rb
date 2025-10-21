# frozen_string_literal: true

class Reading < ApplicationRecord
  belongs_to :user
  belongs_to :book
  belongs_to :purchase_medium, optional: true

  enum :status, {
    wish: 0,             # 気になる
    tsundoku: 1,         # 積読
    completed: 2         # 積読卒業
  }

  validates :status, presence: true
end
