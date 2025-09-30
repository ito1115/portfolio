class Reading < ApplicationRecord
  belongs_to :user
  belongs_to :book

  enum status: {
    wish: 0,       # 読みたい
    tsundoku: 1,   # 積読
    reading: 2,    # 読書中
    completed: 3   # 読了
  }
end
