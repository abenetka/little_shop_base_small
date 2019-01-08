class User < ApplicationRecord
  has_secure_password

  has_many :items, foreign_key: 'merchant_id'
  has_many :orders
  has_many :order_items, through: :orders

  validates_presence_of :name, :address, :city, :state, :zip
  validates :email, presence: true, uniqueness: true

  enum role: [:default, :merchant, :admin]

  def self.top_3_revenue_merchants
    User.joins(items: :order_items)
      .select('users.*, sum(order_items.quantity * order_items.price) as revenue')
      .where('order_items.fulfilled=?', true)
      .order('revenue desc')
      .group(:id)
      .limit(3)
  end

  def self.merchant_fulfillment_times(order, count)
    User.joins(items: :order_items)
      .select('users.*, avg(order_items.updated_at - order_items.created_at) as avg_fulfillment_time')
      .where('order_items.fulfilled=?', true)
      .order("avg_fulfillment_time #{order}")
      .group(:id)
      .limit(count)
  end

  def self.top_3_fulfilling_merchants
    merchant_fulfillment_times(:asc, 3)
  end

  def self.bottom_3_fulfilling_merchants
    merchant_fulfillment_times(:desc, 3)
  end

  def self.top_merchants_items_sold_this_month(count)
    time_range = (Time.now - 1.month)..Time.now
    User.joins(:items, {items: :order_items})
    .select("users.*, sum(order_items.quantity) as items_sold")
    .where(order_items: { updated_at: time_range } )
    .group(:id)
    .order('items_sold desc')
    .limit(count)
  end

  def self.top_merchants_items_sold_last_month(count)
    time_range = (Time.now - 2.month)..(Time.now - 1.month)
    User.joins(:items, {items: :order_items})
    .select("users.*, sum(order_items.quantity) as items_sold")
    .where(order_items: { updated_at: time_range } )
    .group(:id)
    .order('items_sold desc')
    .limit(count)
  end

  def self.top_merchants_fulfilled_orders_this_month(count)
    User.joins('inner join items i on i.merchant_id=users.id inner join order_items oi on oi.item_id=i.id inner join orders o on o.id=oi.order_id')
    .select("users.*, count(distinct o.id) as order_count")
    .where("oi.fulfilled=? AND o.status!=?", true, 2)
    .where('extract(month from oi.updated_at)= ?', 1)
    .group(:id)
    .order("order_count desc")
    .limit(count)
  end

  def self.top_merchants_fulfilled_orders_last_month(count)
    User.joins('inner join items i on i.merchant_id=users.id inner join order_items oi on oi.item_id=i.id inner join orders o on o.id=oi.order_id')
    .select("users.*, count(distinct o.id) as order_count")
    .where("oi.fulfilled=? AND o.status!=?", true, 2)
    .where('extract(month from oi.updated_at)= ?', 12)
    .group(:id)
    .order("order_count desc")
    .limit(count)
  end

  def self.top_merchants_fulfilled_orders_state(current_user)
    order_id_list = Order.joins(:user).where("users.state = ? and orders.status!=?", current_user.state, 2).distinct.pluck(:id)
    User.joins('inner join items i on i.merchant_id=users.id inner join order_items oi on oi.item_id=i.id inner join orders o on o.id=oi.order_id')
      .select("users.*, avg(oi.updated_at - oi.created_at) as avg_f_time")
      .where("o.id in (?) AND oi.fulfilled=?", order_id_list, true)
      .group(:id)
      .order("avg_f_time asc")
      .limit(5)
  end

  def self.top_merchants_fulfilled_orders_city(current_user)
    order_id_list = Order.joins(:user).where("users.city = ? and users.state = ?and orders.status!=?", current_user.city, current_user.state, 2).distinct.pluck(:id)
    User.joins('inner join items i on i.merchant_id=users.id inner join order_items oi on oi.item_id=i.id inner join orders o on o.id=oi.order_id')
      .select("users.*, avg(oi.updated_at - oi.created_at) as avg_f_time")
      .where("o.id in (?) AND oi.fulfilled=?", order_id_list, true)
      .group(:id)
      .order("avg_f_time asc")
      .limit(5)
  end

  def self.total_sales_pie_chart
      User.joins(:items, {items: :order_items})
      .select("users.name")
        .group(:name)
        .sum("order_items.quantity * order_items.price")
  end

  def my_pending_orders
    Order.joins(order_items: :item)
      .where("items.merchant_id=? AND orders.status=? AND order_items.fulfilled=?", self.id, 0, false)
  end

  def inventory_check(item_id)
    return nil unless self.merchant?
    Item.where(id: item_id, merchant_id: self.id).pluck(:inventory).first
  end

  def top_items_by_quantity(count)
    self.items
      .joins(:order_items)
      .select('items.*, sum(order_items.quantity) as quantity_sold')
      .where("order_items.fulfilled = ?", true)
      .group(:id)
      .order('quantity_sold desc')
      .limit(count)
  end

  def quantity_sold_percentage
    sold = self.items.joins(:order_items).where('order_items.fulfilled=?', true).sum('order_items.quantity')
    total = self.items.sum(:inventory) + sold
    {
      sold: sold,
      total: total,
      percentage: ((sold.to_f/total)*100).round(2)
    }
  end

  def top_3_states
    Item.joins('inner join order_items oi on oi.item_id=items.id inner join orders o on o.id=oi.order_id inner join users u on o.user_id=u.id')
      .select('u.state, sum(oi.quantity) as quantity_shipped')
      .where("oi.fulfilled = ? AND items.merchant_id=?", true, self.id)
      .group(:state)
      .order('quantity_shipped desc')
      .limit(3)
  end

  def top_3_cities
    Item.joins('inner join order_items oi on oi.item_id=items.id inner join orders o on o.id=oi.order_id inner join users u on o.user_id=u.id')
      .select('u.city, u.state, sum(oi.quantity) as quantity_shipped')
      .where("oi.fulfilled = ? AND items.merchant_id=?", true, self.id)
      .group(:state, :city)
      .order('quantity_shipped desc')
      .limit(3)
  end

  def most_ordering_user
    User.joins('inner join orders o on o.user_id=users.id inner join order_items oi on oi.order_id=o.id inner join items i on i.id=oi.item_id')
      .select('users.*, count(o.id) as order_count')
      .where("oi.fulfilled = ? AND i.merchant_id=?", true, self.id)
      .group(:id)
      .order('order_count desc')
      .limit(1)
      .first
  end

  def most_items_user
    User.joins('inner join orders o on o.user_id=users.id inner join order_items oi on oi.order_id=o.id inner join items i on i.id=oi.item_id')
      .select('users.*, sum(oi.quantity) as item_count')
      .where("oi.fulfilled = ? AND i.merchant_id=?", true, self.id)
      .group(:id)
      .order('item_count desc')
      .limit(1)
      .first
  end

  def top_3_revenue_users
    User.joins('inner join orders o on o.user_id=users.id inner join order_items oi on oi.order_id=o.id inner join items i on i.id=oi.item_id')
      .select('users.*, sum(oi.quantity*oi.price) as revenue')
      .where("oi.fulfilled = ? AND i.merchant_id=?", true, self.id)
      .group(:id)
      .order('revenue desc')
      .limit(3)
  end

end
