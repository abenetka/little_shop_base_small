require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_presence_of :name }
    it { should validate_presence_of :address }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
  end

  describe 'relationships' do
    it { should have_many :items }
    it { should have_many :orders }
    it { should have_many(:order_items).through(:orders) }
  end

  describe 'class methods' do
    describe 'merchant stats' do
      before :each do
        @user_1 = create(:user, city: 'Denver', state: 'CO')
        @user_2 = create(:user, city: 'NYC', state: 'NY')
        @user_3 = create(:user, city: 'Seattle', state: 'WA')
        @user_4 = create(:user, city: 'Seattle', state: 'FL')

        @merchant_1, @merchant_2, @merchant_3 = create_list(:merchant, 3)
        @item_1 = create(:item, user: @merchant_1)
        @item_2 = create(:item, user: @merchant_2)
        @item_3 = create(:item, user: @merchant_3)

        @order_1 = create(:completed_order, user: @user_1)
        @oi_1 = create(:fulfilled_order_item, item: @item_1, order: @order_1, quantity: 100, price: 100, created_at: 10.minutes.ago, updated_at: 9.minute.ago)

        @order_2 = create(:completed_order, user: @user_2)
        @oi_2 = create(:fulfilled_order_item, item: @item_2, order: @order_2, quantity: 300, price: 300, created_at: 2.days.ago, updated_at: 1.minute.ago)

        @order_3 = create(:completed_order, user: @user_3)
        @oi_3 = create(:fulfilled_order_item, item: @item_3, order: @order_3, quantity: 200, price: 200, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_4 = create(:completed_order, user: @user_4)
        @oi_4 = create(:fulfilled_order_item, item: @item_3, order: @order_4, quantity: 201, price: 200, created_at: 10.minutes.ago, updated_at: 5.minute.ago)
      end
      it '.top_3_revenue_merchants' do
        expect(User.top_3_revenue_merchants[0]).to eq(@merchant_2)
        expect(User.top_3_revenue_merchants[0].revenue.to_f).to eq(90000.00)
        expect(User.top_3_revenue_merchants[1]).to eq(@merchant_3)
        expect(User.top_3_revenue_merchants[1].revenue.to_f).to eq(80200.00)
        expect(User.top_3_revenue_merchants[2]).to eq(@merchant_1)
        expect(User.top_3_revenue_merchants[2].revenue.to_f).to eq(10000.00)
      end
      it '.merchant_fulfillment_times' do
        expect(User.merchant_fulfillment_times(:asc, 1)).to eq([@merchant_1])
        expect(User.merchant_fulfillment_times(:desc, 2)).to eq([@merchant_2, @merchant_3])
      end
      it '.top_3_fulfilling_merchants' do
        expect(User.top_3_fulfilling_merchants[0]).to eq(@merchant_1)
        aft = User.top_3_fulfilling_merchants[0].avg_fulfillment_time
        expect(aft[0..7]).to eq('00:01:00')
        expect(User.top_3_fulfilling_merchants[1]).to eq(@merchant_3)
        aft = User.top_3_fulfilling_merchants[1].avg_fulfillment_time
        expect(aft[0..7]).to eq('00:05:00')
        expect(User.top_3_fulfilling_merchants[2]).to eq(@merchant_2)
        aft = User.top_3_fulfilling_merchants[2].avg_fulfillment_time
        expect(aft[0..13]).to eq('1 day 23:59:00')
      end
      it '.bottom_3_fulfilling_merchants' do
        expect(User.bottom_3_fulfilling_merchants[0]).to eq(@merchant_2)
        aft = User.bottom_3_fulfilling_merchants[0].avg_fulfillment_time
        expect(aft[0..13]).to eq('1 day 23:59:00')
        expect(User.bottom_3_fulfilling_merchants[1]).to eq(@merchant_3)
        aft = User.bottom_3_fulfilling_merchants[1].avg_fulfillment_time
        expect(aft[0..7]).to eq('00:05:00')
        expect(User.bottom_3_fulfilling_merchants[2]).to eq(@merchant_1)
        aft = User.bottom_3_fulfilling_merchants[2].avg_fulfillment_time
        expect(aft[0..7]).to eq('00:01:00')
      end
    end

    describe 'merchant leaderboard top merchants for month' do
      before :each do
        @user_1 = create(:user, city: 'Denver', state: 'CO')
        @user_2 = create(:user, city: 'NYC', state: 'NY')
        @user_3 = create(:user, city: 'Seattle', state: 'WA')
        @user_4 = create(:user, city: 'Seattle', state: 'FL')

        @merchant_1 = create(:merchant, name: 'Merchant Name 1')
        @merchant_2 = create(:merchant, name: 'Merchant Name 2')
        @merchant_3 = create(:merchant, name: 'Merchant Name 3')
        @merchant_4 = create(:merchant, name: 'Merchant Name 4')
        @merchant_5 = create(:merchant, name: 'Merchant Name 5')
        @merchant_6 = create(:merchant, name: 'Merchant Name 6')
        @merchant_7 = create(:merchant, name: 'Merchant Name 7')
        @merchant_8 = create(:merchant, name: 'Merchant Name 8')
        @merchant_9 = create(:merchant, name: 'Merchant Name 9')
        @merchant_10 = create(:merchant, name: 'Merchant Name 10')

        @item_1 = create(:item, user: @merchant_1)
        @item_2 = create(:item, user: @merchant_2)
        @item_3 = create(:item, user: @merchant_3)
        @item_4 = create(:item, user: @merchant_4)
        @item_5 = create(:item, user: @merchant_5)
        @item_6 = create(:item, user: @merchant_6)
        @item_7 = create(:item, user: @merchant_7)
        @item_8 = create(:item, user: @merchant_8)
        @item_9 = create(:item, user: @merchant_9)
        @item_10 = create(:item, user: @merchant_10)

        @order_1 = create(:completed_order, user: @user_1)
        @oi_1 = create(:fulfilled_order_item, item: @item_1, order: @order_1, quantity: 10, price: 11, created_at: 10.minutes.ago, updated_at: 9.minute.ago)

        @order_2 = create(:completed_order, user: @user_2)
        @oi_2 = create(:fulfilled_order_item, item: @item_2, order: @order_2, quantity: 20, price: 12, created_at: 2.days.ago, updated_at: 1.minute.ago)

        @order_3 = create(:completed_order, user: @user_3)
        @oi_3 = create(:fulfilled_order_item, item: @item_3, order: @order_3, quantity: 30, price: 13, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_4 = create(:completed_order, user: @user_4)
        @oi_4 = create(:fulfilled_order_item, item: @item_4, order: @order_4, quantity: 40, price: 14, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_5 = create(:completed_order, user: @user_1)
        @oi_5 = create(:fulfilled_order_item, item: @item_5, order: @order_5, quantity: 50, price: 15, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_6 = create(:completed_order, user: @user_2)
        @oi_6 = create(:fulfilled_order_item, item: @item_6, order: @order_6, quantity: 60, price: 16, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_7 = create(:completed_order, user: @user_3)
        @oi_7 = create(:fulfilled_order_item, item: @item_7, order: @order_7, quantity: 70, price: 17, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_8 = create(:completed_order, user: @user_4)
        @oi_8 = create(:fulfilled_order_item, item: @item_8, order: @order_8, quantity: 80, price: 18, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_9 = create(:completed_order, user: @user_1)
        @oi_9 = create(:fulfilled_order_item, item: @item_9, order: @order_9, quantity: 90, price: 19, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_10 = create(:completed_order, user: @user_2)
        @oi_10 = create(:fulfilled_order_item, item: @item_10, order: @order_10, quantity: 100, price: 20, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_11 = create(:completed_order, user: @user_3)
        @oi_11 = create(:fulfilled_order_item, item: @item_1, order: @order_11, quantity: 200, price: 11, created_at: 3.months.ago, updated_at: 32.days.ago)

        @order_12 = create(:completed_order, user: @user_4)
        @oi_12 = create(:fulfilled_order_item, item: @item_2, order: @order_12, quantity: 190, price: 12, created_at: 3.months.ago, updated_at: 32.days.ago)

        @order_13 = create(:completed_order, user: @user_1)
        @oi_13 = create(:fulfilled_order_item, item: @item_3, order: @order_13, quantity: 180, price: 13, created_at: 3.months.ago, updated_at: 32.days.ago)

        @order_14 = create(:completed_order, user: @user_2)
        @oi_14 = create(:fulfilled_order_item, item: @item_4, order: @order_14, quantity: 170, price: 14, created_at: 3.months.ago, updated_at: 32.days.ago)

        @order_15 = create(:completed_order, user: @user_3)
        @oi_15 = create(:fulfilled_order_item, item: @item_5, order: @order_15, quantity: 160, price: 15, created_at: 3.months.ago, updated_at: 32.days.ago)

        @order_16 = create(:completed_order, user: @user_4)
        @oi_16 = create(:fulfilled_order_item, item: @item_6, order: @order_16, quantity: 150, price: 16, created_at: 3.months.ago, updated_at: 32.days.ago)

        @order_17 = create(:completed_order, user: @user_1)
        @oi_17 = create(:fulfilled_order_item, item: @item_7, order: @order_17, quantity: 140, price: 17, created_at: 3.months.ago, updated_at: 32.days.ago)

        @order_18 = create(:completed_order, user: @user_2)
        @oi_18 = create(:fulfilled_order_item, item: @item_8, order: @order_18, quantity: 130, price: 18, created_at: 3.months.ago, updated_at: 32.days.ago)

        @order_19 = create(:completed_order, user: @user_3)
        @oi_19 = create(:fulfilled_order_item, item: @item_9, order: @order_19, quantity: 120, price: 19, created_at: 3.months.ago, updated_at: 32.days.ago)

        @order_20 = create(:completed_order, user: @user_4)
        @oi_20 = create(:fulfilled_order_item, item: @item_10, order: @order_20, quantity: 110, price: 20, created_at: 3.months.ago, updated_at: 32.days.ago)

        @order_21 = create(:completed_order, user: @user_1)
        @oi_20 = create(:fulfilled_order_item, item: @item_1, order: @order_21, quantity: 2, price: 20, created_at: 3.months.ago, updated_at: 32.days.ago)

        @order_22 = create(:completed_order, user: @user_2)
        @oi_20 = create(:fulfilled_order_item, item: @item_2, order: @order_22, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 32.days.ago)
      end

      it '.top_merchants_items_sold_this_month' do
        expect(User.top_merchants_items_sold_this_month(3)[0]).to eq(@merchant_10)
        expect(User.top_merchants_items_sold_this_month(3).length).to eq(3)
        expect(User.top_merchants_items_sold_this_month(3)[1]).to eq(@merchant_9)
        expect(User.top_merchants_items_sold_this_month(3)[2]).to eq(@merchant_8)
      end

      it '.top_merchants_items_sold_last_month' do
        expect(User.top_merchants_items_sold_last_month(10)[0]).to eq(@merchant_1)
        expect(User.top_merchants_items_sold_last_month(10).length).to eq(10)
        expect(User.top_merchants_items_sold_last_month(10)[1]).to eq(@merchant_2)
        expect(User.top_merchants_items_sold_last_month(10)[2]).to eq(@merchant_3)
      end

    end
    describe 'merchant leaderboard top merchants for month' do
      before :each do
        @user_1 = create(:user, city: 'Denver', state: 'CO')
        @user_2 = create(:user, city: 'NYC', state: 'NY')
        @user_3 = create(:user, city: 'Seattle', state: 'WA')
        @user_4 = create(:user, city: 'Seattle', state: 'FL')

        @merchant_1 = create(:merchant, name: 'Merchant Name 1')
        @merchant_2 = create(:merchant, name: 'Merchant Name 2')
        @merchant_3 = create(:merchant, name: 'Merchant Name 3')
        @merchant_4 = create(:merchant, name: 'Merchant Name 4')
        @merchant_5 = create(:merchant, name: 'Merchant Name 5')
        @merchant_6 = create(:merchant, name: 'Merchant Name 6')
        @merchant_7 = create(:merchant, name: 'Merchant Name 7')
        @merchant_8 = create(:merchant, name: 'Merchant Name 8')
        @merchant_9 = create(:merchant, name: 'Merchant Name 9')
        @merchant_10 = create(:merchant, name: 'Merchant Name 10')

        @item_1 = create(:item, user: @merchant_1)
        @item_2 = create(:item, user: @merchant_2)
        @item_3 = create(:item, user: @merchant_3)
        @item_4 = create(:item, user: @merchant_4)
        @item_5 = create(:item, user: @merchant_5)
        @item_6 = create(:item, user: @merchant_6)
        @item_7 = create(:item, user: @merchant_7)
        @item_8 = create(:item, user: @merchant_8)
        @item_9 = create(:item, user: @merchant_9)
        @item_10 = create(:item, user: @merchant_10)

        @order_1 = create(:completed_order, user: @user_1)
        @oi_1 = create(:fulfilled_order_item, item: @item_1, order: @order_1, quantity: 10, price: 11, created_at: 10.minutes.ago, updated_at: 9.minute.ago)

        @order_2 = create(:completed_order, user: @user_2)
        @oi_2 = create(:fulfilled_order_item, item: @item_1, order: @order_2, quantity: 20, price: 12, created_at: 2.days.ago, updated_at: 1.minute.ago)

        @order_3 = create(:completed_order, user: @user_3)
        @oi_3 = create(:fulfilled_order_item, item: @item_1, order: @order_3, quantity: 30, price: 13, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_4 = create(:completed_order, user: @user_4)
        @oi_4 = create(:fulfilled_order_item, item: @item_1, order: @order_4, quantity: 40, price: 14, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_5 = create(:completed_order, user: @user_1)
        @oi_5 = create(:fulfilled_order_item, item: @item_1, order: @order_5, quantity: 50, price: 15, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_6 = create(:completed_order, user: @user_2)
        @oi_6 = create(:fulfilled_order_item, item: @item_1, order: @order_6, quantity: 60, price: 16, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_7 = create(:completed_order, user: @user_3)
        @oi_7 = create(:fulfilled_order_item, item: @item_1, order: @order_7, quantity: 70, price: 17, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_8 = create(:completed_order, user: @user_4)
        @oi_8 = create(:fulfilled_order_item, item: @item_1, order: @order_8, quantity: 80, price: 18, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_9 = create(:completed_order, user: @user_1)
        @oi_9 = create(:fulfilled_order_item, item: @item_1, order: @order_9, quantity: 90, price: 19, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_10 = create(:completed_order, user: @user_2)
        @oi_10 = create(:fulfilled_order_item, item: @item_1, order: @order_10, quantity: 100, price: 20, created_at: 10.minutes.ago, updated_at: 5.minute.ago)


        @order_11 = create(:completed_order, user: @user_3)
        @oi_11 = create(:fulfilled_order_item, item: @item_2, order: @order_11, quantity: 200, price: 11, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_12 = create(:completed_order, user: @user_4)
        @oi_12 = create(:fulfilled_order_item, item: @item_2, order: @order_12, quantity: 190, price: 12, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_13 = create(:completed_order, user: @user_1)
        @oi_13 = create(:fulfilled_order_item, item: @item_2, order: @order_13, quantity: 180, price: 13, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_14 = create(:completed_order, user: @user_2)
        @oi_14 = create(:fulfilled_order_item, item: @item_2, order: @order_14, quantity: 170, price: 14, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_15 = create(:completed_order, user: @user_3)
        @oi_15 = create(:fulfilled_order_item, item: @item_2, order: @order_15, quantity: 160, price: 15, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_16 = create(:completed_order, user: @user_4)
        @oi_16 = create(:fulfilled_order_item, item: @item_2, order: @order_16, quantity: 150, price: 16, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_17 = create(:completed_order, user: @user_1)
        @oi_17 = create(:fulfilled_order_item, item: @item_2, order: @order_17, quantity: 140, price: 17, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_18 = create(:completed_order, user: @user_2)
        @oi_18 = create(:fulfilled_order_item, item: @item_2, order: @order_18, quantity: 130, price: 18, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_19 = create(:completed_order, user: @user_3)
        @oi_19 = create(:fulfilled_order_item, item: @item_2, order: @order_19, quantity: 120, price: 19, created_at: 2.days.ago, updated_at: 1.day.ago)


        @order_20 = create(:completed_order, user: @user_4)
        @oi_20 = create(:fulfilled_order_item, item: @item_3, order: @order_20, quantity: 110, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_21 = create(:completed_order, user: @user_1)
        @oi_21 = create(:fulfilled_order_item, item: @item_3, order: @order_21, quantity: 2, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_22 = create(:completed_order, user: @user_2)
        @oi_22 = create(:fulfilled_order_item, item: @item_3, order: @order_22, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_23 = create(:completed_order, user: @user_2)
        @oi_23 = create(:fulfilled_order_item, item: @item_3, order: @order_23, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_24 = create(:completed_order, user: @user_2)
        @oi_24 = create(:fulfilled_order_item, item: @item_3, order: @order_24, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_25 = create(:completed_order, user: @user_2)
        @oi_25 = create(:fulfilled_order_item, item: @item_3, order: @order_25, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_26 = create(:completed_order, user: @user_2)
        @oi_26 = create(:fulfilled_order_item, item: @item_3, order: @order_26, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_27 = create(:completed_order, user: @user_2)
        @oi_27 = create(:fulfilled_order_item, item: @item_3, order: @order_27, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)


        @order_28 = create(:completed_order, user: @user_2)
        @oi_28 = create(:fulfilled_order_item, item: @item_4, order: @order_28, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_29 = create(:completed_order, user: @user_2)
        @oi_29 = create(:fulfilled_order_item, item: @item_4, order: @order_29, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_30 = create(:completed_order, user: @user_2)
        @oi_30 = create(:fulfilled_order_item, item: @item_4, order: @order_30, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_31 = create(:completed_order, user: @user_2)
        @oi_31 = create(:fulfilled_order_item, item: @item_4, order: @order_31, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_32 = create(:completed_order, user: @user_2)
        @oi_32 = create(:fulfilled_order_item, item: @item_4, order: @order_32, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_33 = create(:completed_order, user: @user_2)
        @oi_33 = create(:fulfilled_order_item, item: @item_4, order: @order_33, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_34 = create(:completed_order, user: @user_2)
        @oi_34 = create(:fulfilled_order_item, item: @item_4, order: @order_34, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_35 = create(:completed_order, user: @user_2)
        @oi_35 = create(:fulfilled_order_item, item: @item_4, order: @order_35, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)


        @order_36 = create(:completed_order, user: @user_2)
        @oi_36 = create(:fulfilled_order_item, item: @item_5, order: @order_36, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_37 = create(:completed_order, user: @user_2)
        @oi_37 = create(:fulfilled_order_item, item: @item_5, order: @order_37, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_38 = create(:completed_order, user: @user_2)
        @oi_38 = create(:fulfilled_order_item, item: @item_5, order: @order_38, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_39 = create(:completed_order, user: @user_2)
        @oi_39 = create(:fulfilled_order_item, item: @item_5, order: @order_39, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_40 = create(:completed_order, user: @user_2)
        @oi_40 = create(:fulfilled_order_item, item: @item_5, order: @order_40, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_41 = create(:completed_order, user: @user_2)
        @oi_41 = create(:fulfilled_order_item, item: @item_5, order: @order_41, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)


        @order_42 = create(:completed_order, user: @user_2)
        @oi_42 = create(:fulfilled_order_item, item: @item_6, order: @order_42, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_43 = create(:completed_order, user: @user_2)
        @oi_43 = create(:fulfilled_order_item, item: @item_6, order: @order_43, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_44 = create(:completed_order, user: @user_2)
        @oi_44 = create(:fulfilled_order_item, item: @item_6, order: @order_44, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_45 = create(:completed_order, user: @user_2)
        @oi_45 = create(:fulfilled_order_item, item: @item_6, order: @order_45, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_46 = create(:completed_order, user: @user_2)
        @oi_46 = create(:fulfilled_order_item, item: @item_6, order: @order_46, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)


        @order_47 = create(:completed_order, user: @user_2)
        @oi_47 = create(:fulfilled_order_item, item: @item_7, order: @order_47, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_48 = create(:completed_order, user: @user_2)
        @oi_48 = create(:fulfilled_order_item, item: @item_7, order: @order_48, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_49 = create(:completed_order, user: @user_2)
        @oi_49 = create(:fulfilled_order_item, item: @item_7, order: @order_49, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_50 = create(:completed_order, user: @user_2)
        @oi_50 = create(:fulfilled_order_item, item: @item_7, order: @order_50, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)


        @order_51 = create(:completed_order, user: @user_2)
        @oi_51 = create(:fulfilled_order_item, item: @item_8, order: @order_51, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_52 = create(:completed_order, user: @user_2)
        @oi_52 = create(:fulfilled_order_item, item: @item_8, order: @order_52, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_53 = create(:completed_order, user: @user_2)
        @oi_53 = create(:fulfilled_order_item, item: @item_8, order: @order_53, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)


        @order_54 = create(:completed_order, user: @user_2)
        @oi_54 = create(:fulfilled_order_item, item: @item_9, order: @order_54, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_55 = create(:completed_order, user: @user_2)
        @oi_55 = create(:fulfilled_order_item, item: @item_9, order: @order_55, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)


        @order_56 = create(:completed_order, user: @user_2)
        @oi_56 = create(:fulfilled_order_item, item: @item_10, order: @order_56, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        #sad path within time frame, but cancelled
        @order_57 = create(:cancelled_order, user: @user_2)
        @oi_57 = create(:fulfilled_order_item, item: @item_1, order: @order_57, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        @order_58 = create(:cancelled_order, user: @user_2)
        @oi_58 = create(:fulfilled_order_item, item: @item_10, order: @order_58, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

        #sad path cancelled and out of time frame
        @order_59 = create(:cancelled_order, user: @user_2)
        @oi_59 = create(:fulfilled_order_item, item: @item_10, order: @order_59, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 32.days.ago)

        #sad path fulfilled but not in time frame
        @order_60 = create(:completed_order, user: @user_2)
        @oi_60 = create(:fulfilled_order_item, item: @item_10, order: @order_60, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 32.days.ago)
      end

      it '.top_merchants_fulfilled_orders_this_month' do
        expect(User.top_merchants_fulfilled_orders_this_month(5)[0]).to eq(@merchant_1)
        expect(User.top_merchants_fulfilled_orders_this_month(5)[2]).to eq(@merchant_3)
        expect(User.top_merchants_fulfilled_orders_this_month(5)[4]).to eq(@merchant_5)
        expect(User.top_merchants_fulfilled_orders_this_month(5).first.order_count).to eq(10)
        expect(User.top_merchants_fulfilled_orders_this_month(10).last.order_count).to eq(1)
      end
    end

    describe 'merchant leadboard fastest fulfillment times'do
      before :each do
        @user_1 = create(:user, city: 'Denver', state: 'CO')
        @user_2 = create(:user, city: 'NYC', state: 'NY')
        @user_3 = create(:user, city: 'Seattle', state: 'WA')
        @user_4 = create(:user, city: 'Seattle', state: 'FL')

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_3)

        @merchant_1 = create(:merchant, name: 'Merchant Name 1')
        @merchant_2 = create(:merchant, name: 'Merchant Name 2')
        @merchant_3 = create(:merchant, name: 'Merchant Name 3')
        @merchant_4 = create(:merchant, name: 'Merchant Name 4')
        @merchant_5 = create(:merchant, name: 'Merchant Name 5')
        @merchant_6 = create(:merchant, name: 'Merchant Name 6')
        @merchant_7 = create(:merchant, name: 'Merchant Name 7')
        @merchant_8 = create(:merchant, name: 'Merchant Name 8')

        @item_1 = create(:item, user: @merchant_1)
        @item_2 = create(:item, user: @merchant_2)
        @item_3 = create(:item, user: @merchant_3)
        @item_4 = create(:item, user: @merchant_4)
        @item_5 = create(:item, user: @merchant_5)
        @item_6 = create(:item, user: @merchant_6)
        @item_7 = create(:item, user: @merchant_7)
        @item_8 = create(:item, user: @merchant_8)

        @order_1 = create(:completed_order, user: @user_3)
        @oi_1 = create(:fulfilled_order_item, item: @item_1, order: @order_1, quantity: 10, price: 11, created_at: 10.minutes.ago, updated_at: 9.minutes.ago)

        @order_2 = create(:completed_order, user: @user_3)
        @oi_2 = create(:fulfilled_order_item, item: @item_2, order: @order_2, quantity: 20, price: 12, created_at: 10.minutes.ago, updated_at: 8.minutes.ago)

        @order_3 = create(:completed_order, user: @user_3)
        @oi_3 = create(:fulfilled_order_item, item: @item_3, order: @order_3, quantity: 30, price: 13, created_at: 10.minutes.ago, updated_at: 7.minutes.ago)

        @order_4 = create(:completed_order, user: @user_3)
        @oi_4 = create(:fulfilled_order_item, item: @item_4, order: @order_4, quantity: 40, price: 14, created_at: 10.minutes.ago, updated_at: 6.minutes.ago)

        @order_5 = create(:completed_order, user: @user_3)
        @oi_5 = create(:fulfilled_order_item, item: @item_5, order: @order_5, quantity: 50, price: 15, created_at: 10.minutes.ago, updated_at: 5.minutes.ago)

        @order_6 = create(:completed_order, user: @user_4)
        @oi_6 = create(:fulfilled_order_item, item: @item_6, order: @order_6, quantity: 60, price: 16, created_at: 10.minutes.ago, updated_at: 9.minutes.ago)

        @order_7 = create(:cancelled_order, user: @user_3)
        @oi_7 = create(:fulfilled_order_item ,item: @item_7, order: @order_7, quantity: 70, price: 17, created_at: 10.minutes.ago, updated_at: 9.minutes.ago)

        @order_8 = create(:completed_order, user: @user_1)
        @oi_8 = create(:fulfilled_order_item, item: @item_8, order: @order_8, quantity: 80, price: 18, created_at: 10.minutes.ago, updated_at: 9.minutes.ago)
      end

      xit '.top_merchants_fulfilled_orders_state' do
        # binding.pry
        expect(@user_3.top_merchants_fulfilled_orders_state(5)[0]).to eq(@merchant_1)
        # expect(User.top_merchants_fulfilled_orders_state(5)[2]).to eq(@merchant_3)
        # expect(User.top_merchants_fulfilled_orders_state(5)[4]).to eq(@merchant_5)
      end

    end
  end

  describe 'instance methods' do
    it '.my_pending_orders' do
      merchants = create_list(:merchant, 2)
      item_1 = create(:item, user: merchants[0])
      item_2 = create(:item, user: merchants[1])
      orders = create_list(:order, 3)
      create(:order_item, order: orders[0], item: item_1, price: 1, quantity: 1)
      create(:order_item, order: orders[1], item: item_2, price: 1, quantity: 1)
      create(:order_item, order: orders[2], item: item_1, price: 1, quantity: 1)

      expect(merchants[0].my_pending_orders).to eq([orders[0], orders[2]])
      expect(merchants[1].my_pending_orders).to eq([orders[1]])
    end

    it '.inventory_check' do
      admin = create(:admin)
      user = create(:user)
      merchant = create(:merchant)
      item = create(:item, user: merchant, inventory: 100)

      expect(admin.inventory_check(item.id)).to eq(nil)
      expect(user.inventory_check(item.id)).to eq(nil)
      expect(merchant.inventory_check(item.id)).to eq(item.inventory)
    end

    describe 'merchant stats methods' do
      before :each do
        @user_1 = create(:user, city: 'Springfield', state: 'MO')
        @user_2 = create(:user, city: 'Springfield', state: 'CO')
        @user_3 = create(:user, city: 'Las Vegas', state: 'NV')
        @user_4 = create(:user, city: 'Denver', state: 'CO')

        @merchant = create(:merchant)
        @item_1, @item_2, @item_3, @item_4 = create_list(:item, 4, user: @merchant, inventory: 20)

        @order_1 = create(:completed_order, user: @user_1)
        @oi_1a = create(:fulfilled_order_item, order: @order_1, item: @item_1, quantity: 2, price: 100)

        @order_2 = create(:completed_order, user: @user_1)
        @oi_1b = create(:fulfilled_order_item, order: @order_2, item: @item_1, quantity: 1, price: 80)

        @order_3 = create(:completed_order, user: @user_2)
        @oi_2 = create(:fulfilled_order_item, order: @order_3, item: @item_2, quantity: 5, price: 60)

        @order_4 = create(:completed_order, user: @user_3)
        @oi_3 = create(:fulfilled_order_item, order: @order_4, item: @item_3, quantity: 3, price: 40)

        @order_5 = create(:completed_order, user: @user_4)
        @oi_4 = create(:fulfilled_order_item, order: @order_5, item: @item_4, quantity: 4, price: 20)
      end
      it '.top_items_by_quantity' do
        expect(@merchant.top_items_by_quantity(5)).to eq([@item_2, @item_4, @item_1, @item_3])
      end
      it '.quantity_sold_percentage' do
        expect(@merchant.quantity_sold_percentage[:sold]).to eq(15)
        expect(@merchant.quantity_sold_percentage[:total]).to eq(95)
        expect(@merchant.quantity_sold_percentage[:percentage]).to eq(15.79)
      end
      it '.top_3_states' do
        expect(@merchant.top_3_states.first.state).to eq('CO')
        expect(@merchant.top_3_states.first.quantity_shipped).to eq(9)
        expect(@merchant.top_3_states.second.state).to eq('MO')
        expect(@merchant.top_3_states.second.quantity_shipped).to eq(3)
        expect(@merchant.top_3_states.third.state).to eq('NV')
        expect(@merchant.top_3_states.third.quantity_shipped).to eq(3)
      end
      it '.top_3_cities' do
        expect(@merchant.top_3_cities.first.city).to eq('Springfield')
        expect(@merchant.top_3_cities.first.state).to eq('CO')
        expect(@merchant.top_3_cities.second.city).to eq('Denver')
        expect(@merchant.top_3_cities.second.state).to eq('CO')
        expect(@merchant.top_3_cities.third.city).to eq('Springfield')
        expect(@merchant.top_3_cities.third.state).to eq('MO')
      end
      it '.most_ordering_user' do
        expect(@merchant.most_ordering_user).to eq(@user_1)
        expect(@merchant.most_ordering_user.order_count).to eq(2)
      end
      it '.most_items_user' do
        expect(@merchant.most_items_user).to eq(@user_2)
        expect(@merchant.most_items_user.item_count).to eq(5)
      end
      it '.top_3_revenue_users' do
        expect(@merchant.top_3_revenue_users[0]).to eq(@user_2)
        expect(@merchant.top_3_revenue_users[0].revenue).to eq(300)
        expect(@merchant.top_3_revenue_users[1]).to eq(@user_1)
        expect(@merchant.top_3_revenue_users[1].revenue).to eq(280)
        expect(@merchant.top_3_revenue_users[2]).to eq(@user_3)
        expect(@merchant.top_3_revenue_users[2].revenue).to eq(120)
      end
    end
  end
end
