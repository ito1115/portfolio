# frozen_string_literal: true

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

  describe '熟成度機能' do
    describe '#aging_display' do
      context '積読状態の場合' do
        it '0日目はfreshを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: Date.current)
          expect(reading.aging_display).to eq(:fresh)
        end

        it '6日目はfreshを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 6.days.ago)
          expect(reading.aging_display).to eq(:fresh)
        end

        it '7日目はmaturingを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 7.days.ago)
          expect(reading.aging_display).to eq(:maturing)
        end

        it '89日目はmaturingを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 89.days.ago)
          expect(reading.aging_display).to eq(:maturing)
        end

        it '90日目はagedを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 90.days.ago)
          expect(reading.aging_display).to eq(:aged)
        end

        it '364日目はagedを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 364.days.ago)
          expect(reading.aging_display).to eq(:aged)
        end

        it '365日目はvintageを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 365.days.ago)
          expect(reading.aging_display).to eq(:vintage)
        end

        it '1094日目はvintageを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 1094.days.ago)
          expect(reading.aging_display).to eq(:vintage)
        end

        it '1095日目はpremiumを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 1095.days.ago)
          expect(reading.aging_display).to eq(:premium)
        end

        it '1824日目はpremiumを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 1824.days.ago)
          expect(reading.aging_display).to eq(:premium)
        end

        it '1825日目はlegendaryを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 1825.days.ago)
          expect(reading.aging_display).to eq(:legendary)
        end

        it '3000日目はlegendaryを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 3000.days.ago)
          expect(reading.aging_display).to eq(:legendary)
        end
      end

      context '積読状態でない場合' do
        it 'wishステータスの場合はnilを返すこと' do
          reading = create(:reading, status: :wish)
          expect(reading.aging_display).to be_nil
        end

        it 'completedステータスの場合はnilを返すこと' do
          reading = create(:reading, :completed)
          expect(reading.aging_display).to be_nil
        end
      end

      context 'tsundoku_dateがnilの場合' do
        it 'nilを返すこと' do
          reading = create(:reading, status: :tsundoku, tsundoku_date: nil)
          expect(reading.aging_display).to be_nil
        end
      end
    end

    describe '#maturity_badge_with_icon' do
      context '各ランクの場合' do
        it 'freshランクの場合は正しいバッジを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: Date.current)
          expect(reading.maturity_badge_with_icon).to eq('📚 新鮮')
        end

        it 'maturingランクの場合は正しいバッジを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 30.days.ago)
          expect(reading.maturity_badge_with_icon).to eq('🍷 熟成中')
        end

        it 'agedランクの場合は正しいバッジを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 180.days.ago)
          expect(reading.maturity_badge_with_icon).to eq('🏺 熟成済み')
        end

        it 'vintageランクの場合は正しいバッジを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 500.days.ago)
          expect(reading.maturity_badge_with_icon).to eq('💎 ヴィンテージ')
        end

        it 'premiumランクの場合は正しいバッジを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 1200.days.ago)
          expect(reading.maturity_badge_with_icon).to eq('👑 プレミアム')
        end

        it 'legendaryランクの場合は正しいバッジを返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 2000.days.ago)
          expect(reading.maturity_badge_with_icon).to eq('⭐ 伝説級')
        end
      end

      context 'aging_displayがnilの場合' do
        it 'nilを返すこと' do
          reading = create(:reading, status: :wish)
          expect(reading.maturity_badge_with_icon).to be_nil
        end
      end
    end

    describe '#maturity_days' do
      context '積読状態でtsundoku_dateが設定されている場合' do
        it '7日前の場合は7を返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 7.days.ago.to_date)
          expect(reading.maturity_days).to eq(7)
        end

        it '100日前の場合は100を返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: 100.days.ago.to_date)
          expect(reading.maturity_days).to eq(100)
        end

        it '当日の場合は0を返すこと' do
          reading = create(:reading, :tsundoku, tsundoku_date: Date.current)
          expect(reading.maturity_days).to eq(0)
        end
      end

      context '積読状態でない場合' do
        it 'wishステータスの場合はnilを返すこと' do
          reading = create(:reading, status: :wish)
          expect(reading.maturity_days).to be_nil
        end

        it 'completedステータスの場合はnilを返すこと' do
          reading = create(:reading, :completed)
          expect(reading.maturity_days).to be_nil
        end
      end

      context 'tsundoku_dateがnilの場合' do
        it 'nilを返すこと' do
          reading = create(:reading, status: :tsundoku, tsundoku_date: nil)
          expect(reading.maturity_days).to be_nil
        end
      end
    end
  end
end
