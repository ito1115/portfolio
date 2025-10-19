class Reading < ApplicationRecord
  belongs_to :user
  belongs_to :book

  enum status: {
    wish: 0,             # 気になる
    tsundoku: 1,         # 積読
    completed: 2         # 積読卒業
  }
end
