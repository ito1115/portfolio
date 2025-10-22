require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'アソシエーション' do
    it 'readingsを複数持つこと' do
      expect(subject).to have_many(:readings).dependent(:destroy)
    end
  end

  describe 'バリデーション' do
    subject { build(:user) }

    it '有効なファクトリを持つこと' do
      expect(subject).to be_valid
    end

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6) }
  end

  describe '依存関係の削除' do
    it 'ユーザーが削除されたら関連するreadingsも削除されること' do
      user = create(:user)
      create(:reading, user: user)
      expect { user.destroy }.to change { Reading.count }.by(-1)
    end
  end
end
