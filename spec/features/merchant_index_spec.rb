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

        @order_6 = create(:cancelled_order, user: @user_4)
        @oi_6 = create(:fulfilled_order_item, item: @item_6, order: @order_6, quantity: 60, price: 16, created_at: 10.minutes.ago, updated_at: 9.minutes.ago)

        @order_7 = create(:cancelled_order, user: @user_3)
        @oi_7 = create(:fulfilled_order_item ,item: @item_7, order: @order_7, quantity: 70, price: 17, created_at: 10.minutes.ago, updated_at: 9.minutes.ago)


        @order_8 = create(:completed_order, user: @user_4)
        @oi_8 = create(:fulfilled_order_item, item: @item_8, order: @order_8, quantity: 80, price: 18, created_at: 10.minutes.ago, updated_at: 9.minutes.ago)

        @order_9 = create(:completed_order, user: @user_4)
        @oi_9 = create(:fulfilled_order_item, item: @item_9, order: @order_9, quantity: 80, price: 18, created_at: 10.minutes.ago, updated_at: 8.minutes.ago)

        @order_10 = create(:completed_order, user: @user_4)
        @oi_10 = create(:fulfilled_order_item, item: @item_10, order: @order_10, quantity: 80, price: 18, created_at: 10.minutes.ago, updated_at: 7.minutes.ago)

        @order_11 = create(:completed_order, user: @user_4)
        @oi_11 = create(:fulfilled_order_item, item: @item_1, order: @order_11, quantity: 80, price: 18, created_at: 10.minutes.ago, updated_at: 6.minutes.ago)

        @order_12 = create(:completed_order, user: @user_4)
        @oi_12 = create(:fulfilled_order_item, item: @item_2, order: @order_12, quantity: 80, price: 18, created_at: 10.minutes.ago, updated_at: 5.minutes.ago)
      end

      it 'shows top 5 merchants who fulfilled items fastest to a state' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_3)
        visit merchants_path
        within '#leaderboard' do
          within '#top-5-fastest-fulfilled-state' do
            expect(page.all('.merchant')[0]).to have_content("#{@merchant_1.name}")
            expect(page.all('.merchant')[1]).to have_content("#{@merchant_2.name}")
            expect(page.all('.merchant')[2]).to have_content("#{@merchant_3.name}")
            expect(page.all('.merchant')[3]).to have_content("#{@merchant_4.name}")
            expect(page.all('.merchant')[4]).to have_content("#{@merchant_5.name}")
            expect(page.all('.merchant').count).to eq(5)
          end
        end
      end

      it 'shows top 5 merchants who fulfilled items fastest to a city' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_4)
        visit merchants_path
        within '#leaderboard' do
          within '#top-5-fastest-fulfilled-city' do
            expect(page.all('.merchant')[0]).to have_content("#{@merchant_8.name}")
            expect(page.all('.merchant')[1]).to have_content("#{@merchant_9.name}")
            expect(page.all('.merchant')[2]).to have_content("#{@merchant_10.name}")
            expect(page.all('.merchant')[3]).to have_content("#{@merchant_1.name}")
            expect(page.all('.merchant')[4]).to have_content("#{@merchant_2.name}")
            expect(page.all('.merchant').count).to eq(5)
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

  describe 'it shows leaderboard statistics' do
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
  end

  describe 'merchant leaderboard top merchants by month' do
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

      @order_57 = create(:cancelled_order, user: @user_2)
      @oi_57 = create(:fulfilled_order_item, item: @item_1, order: @order_57, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

      @order_58 = create(:cancelled_order, user: @user_2)
      @oi_58 = create(:fulfilled_order_item, item: @item_10, order: @order_58, quantity: 1, price: 20, created_at: 2.days.ago, updated_at: 1.day.ago)

      @order_59 = create(:cancelled_order, user: @user_2)
      @oi_59 = create(:fulfilled_order_item, item: @item_10, order: @order_59, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 4.months.ago)

      @order_60 = create(:completed_order, user: @user_2)
      @oi_60 = create(:fulfilled_order_item, item: @item_10, order: @order_60, quantity: 1, price: 20, created_at: 5.months.ago, updated_at: 4.months.ago)


      @order_61 = create(:completed_order, user: @user_1)
      @oi_61 = create(:fulfilled_order_item, item: @item_10, order: @order_61, quantity: 10, price: 11, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_62 = create(:completed_order, user: @user_2)
      @oi_62 = create(:fulfilled_order_item, item: @item_10, order: @order_62, quantity: 20, price: 12, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_63 = create(:completed_order, user: @user_3)
      @oi_63 = create(:fulfilled_order_item, item: @item_10, order: @order_63, quantity: 30, price: 13, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_64 = create(:completed_order, user: @user_4)
      @oi_64 = create(:fulfilled_order_item, item: @item_10, order: @order_64, quantity: 40, price: 14, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_65 = create(:completed_order, user: @user_1)
      @oi_65 = create(:fulfilled_order_item, item: @item_10, order: @order_65, quantity: 50, price: 15, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_66 = create(:completed_order, user: @user_2)
      @oi_66 = create(:fulfilled_order_item, item: @item_10, order: @order_66, quantity: 60, price: 16, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_67 = create(:completed_order, user: @user_3)
      @oi_67 = create(:fulfilled_order_item, item: @item_10, order: @order_67, quantity: 70, price: 17, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_68 = create(:completed_order, user: @user_4)
      @oi_68 = create(:fulfilled_order_item, item: @item_10, order: @order_68, quantity: 80, price: 18, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_69 = create(:completed_order, user: @user_1)
      @oi_69 = create(:fulfilled_order_item, item: @item_10, order: @order_69, quantity: 90, price: 19, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_70 = create(:completed_order, user: @user_2)
      @oi_70 = create(:fulfilled_order_item, item: @item_10, order: @order_70, quantity: 100, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)


      @order_71 = create(:completed_order, user: @user_3)
      @oi_71 = create(:fulfilled_order_item, item: @item_9, order: @order_71, quantity: 200, price: 11, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_72 = create(:completed_order, user: @user_4)
      @oi_72 = create(:fulfilled_order_item, item: @item_9, order: @order_72, quantity: 190, price: 12, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_73 = create(:completed_order, user: @user_1)
      @oi_73 = create(:fulfilled_order_item, item: @item_9, order: @order_73, quantity: 180, price: 13, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_74 = create(:completed_order, user: @user_2)
      @oi_74 = create(:fulfilled_order_item, item: @item_9, order: @order_74, quantity: 170, price: 14, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_75 = create(:completed_order, user: @user_3)
      @oi_75 = create(:fulfilled_order_item, item: @item_9, order: @order_75, quantity: 160, price: 15, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_76 = create(:completed_order, user: @user_4)
      @oi_76 = create(:fulfilled_order_item, item: @item_9, order: @order_76, quantity: 150, price: 16, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_77 = create(:completed_order, user: @user_1)
      @oi_77 = create(:fulfilled_order_item, item: @item_9, order: @order_77, quantity: 140, price: 17, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_78 = create(:completed_order, user: @user_2)
      @oi_78 = create(:fulfilled_order_item, item: @item_9, order: @order_78, quantity: 130, price: 18, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_79 = create(:completed_order, user: @user_3)
      @oi_79 = create(:fulfilled_order_item, item: @item_9, order: @order_79, quantity: 120, price: 19, created_at: 3.months.ago, updated_at: 30.days.ago)


      @order_80 = create(:completed_order, user: @user_4)
      @oi_80 = create(:fulfilled_order_item, item: @item_8, order: @order_80, quantity: 110, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_81 = create(:completed_order, user: @user_1)
      @oi_81 = create(:fulfilled_order_item, item: @item_8, order: @order_81, quantity: 2, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_82 = create(:completed_order, user: @user_2)
      @oi_82 = create(:fulfilled_order_item, item: @item_8, order: @order_82, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_83 = create(:completed_order, user: @user_2)
      @oi_83 = create(:fulfilled_order_item, item: @item_8, order: @order_83, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_84 = create(:completed_order, user: @user_2)
      @oi_84 = create(:fulfilled_order_item, item: @item_8, order: @order_84, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_85 = create(:completed_order, user: @user_2)
      @oi_85 = create(:fulfilled_order_item, item: @item_8, order: @order_85, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_86 = create(:completed_order, user: @user_2)
      @oi_86 = create(:fulfilled_order_item, item: @item_8, order: @order_86, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_87 = create(:completed_order, user: @user_2)
      @oi_87 = create(:fulfilled_order_item, item: @item_8, order: @order_87, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)


      @order_88 = create(:completed_order, user: @user_2)
      @oi_88 = create(:fulfilled_order_item, item: @item_7, order: @order_88, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_89 = create(:completed_order, user: @user_2)
      @oi_89 = create(:fulfilled_order_item, item: @item_7, order: @order_89, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_90 = create(:completed_order, user: @user_2)
      @oi_90 = create(:fulfilled_order_item, item: @item_7, order: @order_90, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_91 = create(:completed_order, user: @user_2)
      @oi_91 = create(:fulfilled_order_item, item: @item_7, order: @order_91, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_92 = create(:completed_order, user: @user_2)
      @oi_92 = create(:fulfilled_order_item, item: @item_7, order: @order_92, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_93 = create(:completed_order, user: @user_2)
      @oi_93 = create(:fulfilled_order_item, item: @item_7, order: @order_93, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_94 = create(:completed_order, user: @user_2)
      @oi_94 = create(:fulfilled_order_item, item: @item_7, order: @order_94, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)


      @order_96 = create(:completed_order, user: @user_2)
      @oi_96 = create(:fulfilled_order_item, item: @item_6, order: @order_96, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_97 = create(:completed_order, user: @user_2)
      @oi_97 = create(:fulfilled_order_item, item: @item_6, order: @order_97, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_98 = create(:completed_order, user: @user_2)
      @oi_98 = create(:fulfilled_order_item, item: @item_6, order: @order_98, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_99 = create(:completed_order, user: @user_2)
      @oi_99 = create(:fulfilled_order_item, item: @item_6, order: @order_99, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_100 = create(:completed_order, user: @user_2)
      @oi_100 = create(:fulfilled_order_item, item: @item_6, order: @order_100, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_101 = create(:completed_order, user: @user_2)
      @oi_101 = create(:fulfilled_order_item, item: @item_6, order: @order_101, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)


      @order_102 = create(:completed_order, user: @user_2)
      @oi_102 = create(:fulfilled_order_item, item: @item_5, order: @order_102, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_103 = create(:completed_order, user: @user_2)
      @oi_103 = create(:fulfilled_order_item, item: @item_5, order: @order_103, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_104 = create(:completed_order, user: @user_2)
      @oi_104 = create(:fulfilled_order_item, item: @item_5, order: @order_104, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_105 = create(:completed_order, user: @user_2)
      @oi_105 = create(:fulfilled_order_item, item: @item_5, order: @order_105, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_106 = create(:completed_order, user: @user_2)
      @oi_106 = create(:fulfilled_order_item, item: @item_5, order: @order_106, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)


      @order_107 = create(:completed_order, user: @user_2)
      @oi_107 = create(:fulfilled_order_item, item: @item_4, order: @order_107, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_108 = create(:completed_order, user: @user_2)
      @oi_108 = create(:fulfilled_order_item, item: @item_4, order: @order_108, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_109 = create(:completed_order, user: @user_2)
      @oi_109 = create(:fulfilled_order_item, item: @item_4, order: @order_109, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_110 = create(:completed_order, user: @user_2)
      @oi_110 = create(:fulfilled_order_item, item: @item_4, order: @order_110, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)


      @order_111 = create(:completed_order, user: @user_2)
      @oi_111 = create(:fulfilled_order_item, item: @item_3, order: @order_111, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_112 = create(:completed_order, user: @user_2)
      @oi_112 = create(:fulfilled_order_item, item: @item_3, order: @order_112, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_113 = create(:completed_order, user: @user_2)
      @oi_113 = create(:fulfilled_order_item, item: @item_3, order: @order_113, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)


      @order_114 = create(:completed_order, user: @user_2)
      @oi_114 = create(:fulfilled_order_item, item: @item_2, order: @order_114, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_115 = create(:completed_order, user: @user_2)
      @oi_115 = create(:fulfilled_order_item, item: @item_2, order: @order_115, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)


      @order_116 = create(:completed_order, user: @user_2)
      @oi_116 = create(:fulfilled_order_item, item: @item_1, order: @order_116, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)

      @order_117 = create(:cancelled_order, user: @user_2)
      @oi_117 = create(:fulfilled_order_item, item: @item_1, order: @order_117, quantity: 1, price: 20, created_at: 3.months.ago, updated_at: 30.days.ago)
    end

    it 'shows top 10 merchants who fulfilled non-cancelled orders this month' do
      visit merchants_path
      within '#leaderboard' do
        within '#top-10-merchants-fulfilled-orders-this-month' do
          expect(page.all('.merchant')[0]).to have_content("#{@merchant_1.name}, Orders: 10")
          expect(page.all('.merchant')[1]).to have_content("#{@merchant_2.name}, Orders: 9")
          expect(page.all('.merchant')[2]).to have_content("#{@merchant_3.name}, Orders: 8")
          expect(page.all('.merchant')[3]).to have_content("#{@merchant_4.name}, Orders: 7")
          expect(page.all('.merchant')[4]).to have_content("#{@merchant_5.name}, Orders: 6")
          expect(page.all('.merchant')[5]).to have_content("#{@merchant_6.name}, Orders: 5")
          expect(page.all('.merchant')[6]).to have_content("#{@merchant_7.name}, Orders: 4")
          expect(page.all('.merchant')[7]).to have_content("#{@merchant_8.name}, Orders: 3")
          expect(page.all('.merchant')[8]).to have_content("#{@merchant_9.name}, Orders: 2")
          expect(page.all('.merchant')[9]).to have_content("#{@merchant_10.name}, Orders: 1")
        end
      end
    end

    it 'shows top 10 merchants who fulfilled non-cancelled orders last month' do
      visit merchants_path
      within '#leaderboard' do
        within '#top-10-merchants-fulfilled-orders-last-month' do
          expect(page.all('.merchant')[0]).to have_content("#{@merchant_10.name}, Orders: 10")
          expect(page.all('.merchant')[1]).to have_content("#{@merchant_9.name}, Orders: 9")
          expect(page.all('.merchant')[2]).to have_content("#{@merchant_8.name}, Orders: 8")
          expect(page.all('.merchant')[3]).to have_content("#{@merchant_7.name}, Orders: 7")
          expect(page.all('.merchant')[4]).to have_content("#{@merchant_6.name}, Orders: 6")
          expect(page.all('.merchant')[5]).to have_content("#{@merchant_5.name}, Orders: 5")
          expect(page.all('.merchant')[6]).to have_content("#{@merchant_4.name}, Orders: 4")
          expect(page.all('.merchant')[7]).to have_content("#{@merchant_3.name}, Orders: 3")
          expect(page.all('.merchant')[8]).to have_content("#{@merchant_2.name}, Orders: 2")
          expect(page.all('.merchant')[9]).to have_content("#{@merchant_1.name}, Orders: 1")
        end
      end
    end

  end
end
