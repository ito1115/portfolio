# frozen_string_literal: true

FactoryBot.define do
  factory :book do
    sequence(:title) { |n| "Book Title #{n}" }
    author { 'Author Name' }
    publisher { 'Publisher Name' }
    published_date { '2024-01-01' }
    description { 'This is a book description.' }
    isbn { '978-4-1234-5678-9' }
    image_url { 'https://example.com/book.jpg' }
  end
end
