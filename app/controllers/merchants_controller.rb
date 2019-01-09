class MerchantsController < ApplicationController
  before_action :require_merchant, only: :show

  def index
    flags = {role: :merchant}
    unless current_admin?
      flags[:active] = true
    end
    @merchants = User.where(flags)
    if current_user
      @user = current_user
      @top_5_merchants_fulfilled_orders_state = User.top_merchants_fulfilled_orders_state(@user)
      @top_5_merchants_fulfilled_orders_city = User.top_merchants_fulfilled_orders_city(@user)
    end
    @top_3_revenue_merchants = User.top_3_revenue_merchants
    @top_3_fulfilling_merchants = User.top_3_fulfilling_merchants
    @bottom_3_fulfilling_merchants = User.bottom_3_fulfilling_merchants
    @top_3_states = Order.top_3_states
    @top_3_cities = Order.top_3_cities
    @top_3_quantity_orders = Order.top_3_quantity_orders
    @top_10_merchants_items_sold_this_month = User.top_merchants_items_sold_this_month(10)
    @top_10_merchants_items_sold_last_month = User.top_merchants_items_sold_last_month(10)
    @top_10_merchants_fulfilled_orders_this_month = User.top_merchants_fulfilled_orders_this_month(10)
    @top_10_merchants_fulfilled_orders_last_month = User.top_merchants_fulfilled_orders_last_month(10)
    @sales_for_year = OrderItem.sales_for_year
    @total_sales_pie_chart = User.total_sales_pie_chart
    @total_sales = User.total_sales
  end

  def show
    @merchant = current_user
    @orders = @merchant.my_pending_orders
    @top_5_items = @merchant.top_items_by_quantity(5)
    @qsp = @merchant.quantity_sold_percentage
    @top_3_states = @merchant.top_3_states
    @top_3_cities = @merchant.top_3_cities
    @most_ordering_user = @merchant.most_ordering_user
    @most_items_user = @merchant.most_items_user
    @most_items_user = @merchant.most_items_user
    @top_3_revenue_users = @merchant.top_3_revenue_users
    @pie_quantity_sold_percentage= @merchant.pie_quantity_sold_percentage
  end

  private

  def require_merchant
    render file: 'errors/not_found', status: 404 unless current_user && current_merchant?
  end
end
