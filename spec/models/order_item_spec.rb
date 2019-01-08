require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'validations' do
    it { should validate_presence_of :price }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of :quantity }
    it { should validate_numericality_of(:quantity).only_integer }
    it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1) }
  end

  describe 'relationships' do
    it { should belong_to :order }
    it { should belong_to :item }
  end

  describe 'class methods' do
    describe 'sales by month' do
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
        @oi_1 = create(:fulfilled_order_item, item: @item_1, order: @order_1, quantity: 10, price: 11, created_at: 13.months.ago, updated_at: 1.minute.ago)

        @order_2 = create(:completed_order, user: @user_2)
        @oi_2 = create(:fulfilled_order_item, item: @item_1, order: @order_2, quantity: 20, price: 12, created_at: 13.months.ago, updated_at: 1.month.ago)

        @order_3 = create(:completed_order, user: @user_3)
        @oi_3 = create(:fulfilled_order_item, item: @item_1, order: @order_3, quantity: 30, price: 13, created_at: 13.months.ago, updated_at: 2.months.ago)

        @order_4 = create(:completed_order, user: @user_4)
        @oi_4 = create(:fulfilled_order_item, item: @item_1, order: @order_4, quantity: 40, price: 14, created_at: 13.months.ago, updated_at: 3.months.ago)

        @order_5 = create(:completed_order, user: @user_1)
        @oi_5 = create(:fulfilled_order_item, item: @item_1, order: @order_5, quantity: 50, price: 15, created_at: 13.months.ago, updated_at: 4.months.ago)

        @order_6 = create(:completed_order, user: @user_2)
        @oi_6 = create(:fulfilled_order_item, item: @item_1, order: @order_6, quantity: 60, price: 16, created_at: 13.months.ago, updated_at: 5.months.ago)

        @order_7 = create(:completed_order, user: @user_3)
        @oi_7 = create(:fulfilled_order_item, item: @item_1, order: @order_7, quantity: 70, price: 17, created_at: 13.months.ago, updated_at: 6.months.ago)

        @order_8 = create(:completed_order, user: @user_4)
        @oi_8 = create(:fulfilled_order_item, item: @item_1, order: @order_8, quantity: 80, price: 18, created_at: 13.months.ago, updated_at: 7.months.ago)

        @order_9 = create(:completed_order, user: @user_1)
        @oi_9 = create(:fulfilled_order_item, item: @item_1, order: @order_9, quantity: 90, price: 19, created_at: 13.months.ago, updated_at: 8.months.ago)

        @order_10 = create(:completed_order, user: @user_2)
        @oi_10 = create(:fulfilled_order_item, item: @item_1, order: @order_10, quantity: 100, price: 20, created_at: 13.months.ago, updated_at: 9.months.ago)

        @order_11 = create(:completed_order, user: @user_3)
        @oi_11 = create(:fulfilled_order_item, item: @item_2, order: @order_11, quantity: 200, price: 11, created_at: 13.months.ago, updated_at: 10.months.ago)

        @order_12 = create(:completed_order, user: @user_4)
        @oi_12 = create(:fulfilled_order_item, item: @item_2, order: @order_12, quantity: 190, price: 12, created_at: 13.months.ago, updated_at: 11.months.ago)

        @order_13 = create(:completed_order, user: @user_1)
        @oi_13 = create(:fulfilled_order_item, item: @item_2, order: @order_13, quantity: 180, price: 13, created_at: 13.months.ago, updated_at: 12.months.ago)
      end

      it 'calculates total sales by month' do
        expected = ({"Jan"=>0.234e4,"Feb"=>0.228e4, "Mar"=>0.22e4,
                    "Apr"=>0.2e4, "May"=>0.171e4, "Jun"=>0.144e4,
                    "Jun"=>0.144e4,"Jul"=>0.119e4, "Aug"=>0.96e3,
                    "Sep"=>0.75e3,  "Oct"=>0.56e3, "Nov"=>0.39e3,
                    "Dec"=>0.24e3})

        expect(OrderItem.sales_for_year.first[0]).to eq("Jan")
        expect(OrderItem.sales_for_year.first[1]).to eq(2340)
        expect(OrderItem.sales_for_year["Jan"]).to eq(2340)
        expect(OrderItem.sales_for_year["Aug"]).to eq(960)
        expect(OrderItem.sales_for_year).to eq(expected)
      end
    end
  end

  describe 'instance methods' do
    it '.subtotal' do
      oi = create(:order_item, quantity: 5, price: 3)

      expect(oi.subtotal).to eq(15)
    end
  end
end
