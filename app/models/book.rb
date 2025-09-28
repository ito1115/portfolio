class Book < ApplicationRecord
  has_many :readings, dependent: :destroy
end
