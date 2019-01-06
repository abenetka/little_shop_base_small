require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :price }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of :description }
    it { should validate_presence_of :inventory }
    it { should validate_numericality_of(:inventory).only_integer }
    it { should validate_numericality_of(:inventory).is_greater_than_or_equal_to(0) }
  end

  describe 'relationships' do
    it { should belong_to :user }
    it { should have_many :order_items }
    it { should have_many(:orders).through(:order_items) }
  end

  describe 'class methods' do
    describe 'item popularity' do
      before :each do
        merchant = create(:merchant)
        @items = create_list(:item, 6, user: merchant)
        user = create(:user)

        order = create(:completed_order, user: user)
        create(:fulfilled_order_item, order: order, item: @items[3], quantity: 7)
        create(:fulfilled_order_item, order: order, item: @items[1], quantity: 6)
        create(:fulfilled_order_item, order: order, item: @items[0], quantity: 5)
        create(:fulfilled_order_item, order: order, item: @items[2], quantity: 3)
        create(:fulfilled_order_item, order: order, item: @items[5], quantity: 2)
        create(:fulfilled_order_item, order: order, item: @items[4], quantity: 1)
      end
      it '.item_popularity' do
        expect(Item.item_popularity(4, :desc)).to eq([@items[3], @items[1], @items[0], @items[2]])
        expect(Item.item_popularity(4, :asc)).to eq([@items[4], @items[5], @items[2], @items[0]])
      end
      it '.popular_items' do
        expect(Item.popular_items(3)).to eq([@items[3], @items[1], @items[0]])
      end
      it '.unpopular_items' do
        expect(Item.unpopular_items(3)).to eq([@items[4], @items[5], @items[2]])
      end
    end

    describe 'merchant total inventory sold' do
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

        @item_1 = create(:item, user: @merchant_1, inventory: 2)
        @item_2 = create(:item, user: @merchant_2, inventory: 3)
        @item_3 = create(:item, user: @merchant_3, inventory: 4)
        @item_4 = create(:item, user: @merchant_4, inventory: 5)
        @item_5 = create(:item, user: @merchant_5, inventory: 6)

        @order_1 = create(:completed_order, user: @user_1)
        @oi_1 = create(:fulfilled_order_item, item: @item_1, order: @order_1, quantity: 1, price: 11, created_at: 10.minutes.ago, updated_at: 9.minute.ago)

        @order_2 = create(:completed_order, user: @user_2)
        @oi_2 = create(:fulfilled_order_item, item: @item_2, order: @order_2, quantity: 1, price: 12, created_at: 2.days.ago, updated_at: 1.minute.ago)

        @order_3 = create(:completed_order, user: @user_3)
        @oi_3 = create(:fulfilled_order_item, item: @item_3, order: @order_3, quantity: 1, price: 13, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_4 = create(:completed_order, user: @user_4)
        @oi_4 = create(:fulfilled_order_item, item: @item_4, order: @order_4, quantity: 1, price: 14, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_5 = create(:completed_order, user: @user_1)
        @oi_5 = create(:fulfilled_order_item, item: @item_5, order: @order_5, quantity: 1, price: 15, created_at: 10.minutes.ago, updated_at: 5.minute.ago)
      end

      it '.total_inventory' do
        expect(Item.total_inventory).to eq(25)
      end

      it '.current_inventory' do
        expect(Item.current_inventory).to eq(20)
      end

      it '.percent_total_inventory_sold' do
        expect(Item.percent_total_inventory_sold).to eq(80.00)
      end
    end
  end

  describe 'instance methods' do
    it '.avg_fulfillment_time' do
      item = create(:item)
      merchant = item.user
      user = create(:user)
      order = create(:completed_order, user: user)
      create(:fulfilled_order_item, order: order, item: item, created_at: 4.days.ago, updated_at: 1.days.ago)
      create(:fulfilled_order_item, order: order, item: item, created_at: 1.hour.ago, updated_at: 30.minutes.ago)

      expect(item.avg_fulfillment_time).to include("1 day 12:15:00")
    end

    it '.ever_ordered?' do
      item_1 = create(:item)
      item_2 = create(:item)
      order = create(:completed_order)
      create(:fulfilled_order_item, order: order, item: item_1, created_at: 4.days.ago, updated_at: 1.days.ago)

      expect(item_1.ever_ordered?).to eq(true)
      expect(item_2.ever_ordered?).to eq(false)
    end
  end


end
