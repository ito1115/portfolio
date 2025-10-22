require 'rails_helper'

RSpec.describe Reading, type: :model do
  describe 'アソシエーション' do
    it 'userに属すること' do
      expect(subject).to belong_to(:user)
    end

    it 'bookに属すること' do
      expect(subject).to belong_to(:book)
    end

    it 'purchase_mediumに属すること（任意）' do
      expect(subject).to belong_to(:purchase_medium).optional
    end
  end

  describe 'バリデーション' do
    subject { build(:reading) }

    it '有効なファクトリを持つこと' do
      expect(subject).to be_valid
    end

    it { should validate_presence_of(:status) }
    it { should define_enum_for(:status).with_values(wish: 0, tsundoku: 1, completed: 2) }
  end

  describe 'ステータス遷移' do
    let(:reading) { create(:reading) }

    it 'wishからtsundokuに変更できること' do
      expect(reading.wish?).to be true
      reading.update(status: :tsundoku, tsundoku_date: Date.current)
      expect(reading.tsundoku?).to be true
    end

    it 'tsundokuからcompletedに変更できること' do
      reading = create(:reading, :tsundoku)
      expect(reading.tsundoku?).to be true
      reading.update(status: :completed, completed_date: Date.current)
      expect(reading.completed?).to be true
    end

    it 'wishからcompletedに直接変更できること' do
      expect(reading.wish?).to be true
      reading.update(status: :completed, completed_date: Date.current)
      expect(reading.completed?).to be true
    end
  end

  describe 'ファクトリのtrait' do
    it 'tsundoku traitが正しく動作すること' do
      reading = create(:reading, :tsundoku)
      expect(reading.tsundoku?).to be true
      expect(reading.tsundoku_date).not_to be_nil
    end

    it 'completed traitが正しく動作すること' do
      reading = create(:reading, :completed)
      expect(reading.completed?).to be true
      expect(reading.completed_date).not_to be_nil
    end
  end
end
