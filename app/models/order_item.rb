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
    OrderItem
    .where('extract(year from order_items.updated_at)= ?', 2018)
    .group_by_month(:updated_at, format: "%b")
    .sum("quantity * price")
  end

end
