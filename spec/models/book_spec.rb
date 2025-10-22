require 'rails_helper'

RSpec.describe Book, type: :model do
  describe 'アソシエーション' do
    it 'readingsを複数持つこと' do
      expect(subject).to have_many(:readings).dependent(:destroy)
    end
  end

  describe 'バリデーション' do
    subject { build(:book) }

    it '有効なファクトリを持つこと' do
      expect(subject).to be_valid
    end

    it { should validate_presence_of(:title) }
  end

  describe '依存関係の削除' do
    it '本が削除されたら関連するreadingsも削除されること' do
      book = create(:book)
      create(:reading, book: book)
      expect { book.destroy }.to change { Reading.count }.by(-1)
    end
  end
end
