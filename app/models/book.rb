class Book < ApplicationRecord
  belongs_to :user
  has_many :reading, dependent: :destory
end
