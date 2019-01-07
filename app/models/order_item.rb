class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item

  validates :price, presence: true, numericality: {
    only_integer: false,
    greater_than_or_equal_to: 0
  }
  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }

  def subtotal
    quantity * price
  end

  def self.sales_for_year
    OrderItem.select("*, sum(order_items.quantity * order_items.price) as revenue, date_trunc('month', order_items.updated_at) as month")
    .where('extract(year from order_items.updated_at)= ?', 2018)
    .group(:id)
    .group('month')
    .order('month')
  end
  
end
