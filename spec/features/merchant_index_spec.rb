require 'rails_helper'

RSpec.describe 'Merchant Index Page', type: :feature do
  before :each do
    @merchant = create(:merchant)
    @inactive_merchant = create(:inactive_merchant)
  end
  context 'as a non-admin user' do
    it 'should show all active merchants' do
      visit merchants_path

      within "#merchant-#{@merchant.id}" do
        expect(page).to have_content("#{@merchant.name}, #{@merchant.city} #{@merchant.state}")
        expect(page).to have_content(@merchant.created_at)
      end
      expect(page).to_not have_content(@inactive_merchant.name)
    end
    describe 'it shows statistics' do
      before :each do
        @user_1 = create(:user, city: 'Denver', state: 'CO')
        @user_2 = create(:user, city: 'NYC', state: 'NY')
        @user_3 = create(:user, city: 'Seattle', state: 'WA')
        @user_4 = create(:user, city: 'Seattle', state: 'FL')

        @merchant_1 = create(:merchant, name: 'Merchant Name 1')
        @merchant_2 = create(:merchant, name: 'Merchant Name 2')
        @merchant_3 = create(:merchant, name: 'Merchant Name 3')

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

=begin
- top 3 states where any orders were shipped
NY, WA, FL
- top 3 cities where any orders were shipped (Springfield, MI should not be grouped with Springfield, CO)
NYC, Seattle WA, Seattle FL
- top 3 biggest orders by quantity of items
2, 3, 4
=end
      it 'shows top 3 merchants by revenue' do
        visit merchants_path
        within '#statistics' do
          within '#top-3-revenue-merchants' do
            expect(page.all('.merchant')[0]).to have_content('Merchant Name 2, Revenue: $90,000')
            expect(page.all('.merchant')[1]).to have_content('Merchant Name 3, Revenue: $80,200')
            expect(page.all('.merchant')[2]).to have_content('Merchant Name 1, Revenue: $10,000')
          end
        end
      end
      it 'shows top 3 merchants by fastest average fulfillment time' do
        visit merchants_path
        within '#statistics' do
          within '#top-3-fulfilling-merchants' do
            expect(page.all('.merchant')[0]).to have_content('Merchant Name 1, Average Fulfillment Time: 1 minute')
            expect(page.all('.merchant')[1]).to have_content('Merchant Name 3, Average Fulfillment Time: 5 minutes')
            expect(page.all('.merchant')[2]).to have_content('Merchant Name 2, Average Fulfillment Time: 1 day, 23 hours, 59 minutes')
          end
        end
      end
      it 'shows worst 3 merchants by slowest average fulfillment time' do
        visit merchants_path
        within '#statistics' do
          within '#bottom-3-fulfilling-merchants' do
            expect(page.all('.merchant')[0]).to have_content('Merchant Name 2, Average Fulfillment Time: 1 day, 23 hours, 59 minutes')
            expect(page.all('.merchant')[1]).to have_content('Merchant Name 3, Average Fulfillment Time: 5 minutes')
            expect(page.all('.merchant')[2]).to have_content('Merchant Name 1, Average Fulfillment Time: 1 minute')
          end
        end
      end
      it 'shows top 3 states where orders were shipped' do
        visit merchants_path
        within '#statistics' do
          within '#top-3-states-shipped' do
            expect(page.all('.state')[0]).to have_content('CO, 1 order')
            expect(page.all('.state')[1]).to have_content('FL, 1 order')
            expect(page.all('.state')[2]).to have_content('NY, 1 order')
          end
        end
      end
      it 'shows top 3 cities where orders were shipped' do
        visit merchants_path
        within '#statistics' do
          within '#top-3-cities-shipped' do
            expect(page.all('.city')[0]).to have_content('Denver CO, 1 order')
            expect(page.all('.city')[1]).to have_content('NYC NY, 1 order')
            expect(page.all('.city')[2]).to have_content('Seattle FL, 1 order')
          end
        end
      end
      it 'shows top orders by quantity of items' do
        visit merchants_path
        within '#statistics' do
          within '#top-3-quantity-orders' do
            expect(page.all('.order')[0]).to have_content('User Name 2 bought 300 items in one order')
            expect(page.all('.order')[1]).to have_content('User Name 4 bought 201 items in one order')
            expect(page.all('.order')[2]).to have_content('User Name 3 bought 200 items in one order')
          end
        end
      end
    end


    describe 'it shows stats to logged in users' do
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

      xit 'shows top 5 merchants who fulfilled items fastest to a state' do
        visit merchants_path
        within '#leaderboard' do
          within '#top-5-fastest-fulfilled-state' do
            expect(page.all('.merchant')[0]).to have_content("#{@merchant_1.name}")
            expect(page.all('.merchant')[1]).to have_content("#{@merchant_2.name}")
            expect(page.all('.merchant')[2]).to have_content("#{@merchant_3.name}")
            expect(page.all('.merchant')[3]).to have_content("#{@merchant_4.name}")
            expect(page.all('.merchant')[4]).to have_content("#{@merchant_5.name}")
            expect(page).to_not have_conent("#{@merchant_6.name}")
            expect(page).to_not have_conent("#{@merchant_7.name}")
            expect(page).to_not have_conent("#{@merchant_8.name}")
          end
        end
      end
    end
  end

  context 'as an admin user' do
    before :each do
      admin = create(:admin)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
    end
    it 'should show all merchants with enable/disable buttons' do
      visit merchants_path

      within "#merchant-#{@merchant.id}" do
        expect(page).to have_link(@merchant.name)
        expect(page).to have_content("#{@merchant.name}, #{@merchant.city} #{@merchant.state}")
        expect(page).to have_content(@merchant.created_at)
        expect(page).to have_button('Disable')
      end
      within "#merchant-#{@inactive_merchant.id}" do
        expect(page).to have_link(@inactive_merchant.name)
        expect(page).to have_content("#{@inactive_merchant.name}, #{@inactive_merchant.city} #{@inactive_merchant.state}")
        expect(page).to have_content(@inactive_merchant.created_at)
        expect(page).to have_button('Enable')
      end
    end
    it 'should show an admin user a merchant dashboard' do
      visit merchants_path

      within "#merchant-#{@merchant.id}" do
        click_link(@merchant.name)
      end

      expect(current_path).to eq(admin_merchant_path(@merchant))
      expect(page).to have_content("Merchant Dashboard for #{@merchant.name}")
    end
  end

  describe 'it show leaderboard statistics' do
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
    end

    it 'shows top 10 merchants who sold the most items this month' do
      visit merchants_path
      within '#leaderboard' do
        within '#top-10-merchants-items-sold-this-month' do
          expect(page.all('.merchant')[0]).to have_content('Merchant Name 10, Items Sold: 100')
          expect(page.all('.merchant')[1]).to have_content('Merchant Name 9, Items Sold: 90')
          expect(page.all('.merchant')[2]).to have_content('Merchant Name 8, Items Sold: 80')
          expect(page.all('.merchant')[3]).to have_content('Merchant Name 7, Items Sold: 70')
          expect(page.all('.merchant')[4]).to have_content('Merchant Name 6, Items Sold: 60')
          expect(page.all('.merchant')[5]).to have_content('Merchant Name 5, Items Sold: 50')
          expect(page.all('.merchant')[6]).to have_content('Merchant Name 4, Items Sold: 40')
          expect(page.all('.merchant')[7]).to have_content('Merchant Name 3, Items Sold: 30')
          expect(page.all('.merchant')[8]).to have_content('Merchant Name 2, Items Sold: 20')
          expect(page.all('.merchant')[9]).to have_content('Merchant Name 1, Items Sold: 10')
        end
      end
    end

    it 'shows top 10 merchants who sold the most items last month' do
      visit merchants_path
      within '#leaderboard' do
        within '#top-10-merchants-items-sold-last-month' do
          expect(page.all('.merchant')[0]).to have_content('Merchant Name 1, Items Sold: 200')
          expect(page.all('.merchant')[1]).to have_content('Merchant Name 2, Items Sold: 190')
          expect(page.all('.merchant')[2]).to have_content('Merchant Name 3, Items Sold: 180')
          expect(page.all('.merchant')[3]).to have_content('Merchant Name 4, Items Sold: 170')
          expect(page.all('.merchant')[4]).to have_content('Merchant Name 5, Items Sold: 160')
          expect(page.all('.merchant')[5]).to have_content('Merchant Name 6, Items Sold: 150')
          expect(page.all('.merchant')[6]).to have_content('Merchant Name 7, Items Sold: 140')
          expect(page.all('.merchant')[7]).to have_content('Merchant Name 8, Items Sold: 130')
          expect(page.all('.merchant')[8]).to have_content('Merchant Name 9, Items Sold: 120')
          expect(page.all('.merchant')[9]).to have_content('Merchant Name 10, Items Sold: 110')
        end
      end
    end

    xit 'shows top 10 merchants who fulfilled non-cancelled orders this month' do
      visit merchants_path
      within '#leaderboard' do
        within '#top-10-merchants-fulfilled-orders-this-month' do
          # expect(page.all('.merchant')[0]).to have_content('Merchant Name 1, Items Sold: 200')
          # expect(page.all('.merchant')[1]).to have_content('Merchant Name 2, Items Sold: 190')
          # expect(page.all('.merchant')[2]).to have_content('Merchant Name 3, Items Sold: 180')
          # expect(page.all('.merchant')[3]).to have_content('Merchant Name 4, Items Sold: 170')
          # expect(page.all('.merchant')[4]).to have_content('Merchant Name 5, Items Sold: 160')
          # expect(page.all('.merchant')[5]).to have_content('Merchant Name 6, Items Sold: 150')
          # expect(page.all('.merchant')[6]).to have_content('Merchant Name 7, Items Sold: 140')
          # expect(page.all('.merchant')[7]).to have_content('Merchant Name 8, Items Sold: 130')
          # expect(page.all('.merchant')[8]).to have_content('Merchant Name 9, Items Sold: 120')
          # expect(page.all('.merchant')[9]).to have_content('Merchant Name 10, Items Sold: 110')
        end
      end
    end

  end
end
