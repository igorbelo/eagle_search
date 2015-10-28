require 'active_record'
require 'eagle_search'

ENV['RAILS_ENV'] ||= "test"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Migration.create_table :products do |t|
  t.string :name
  t.text :description
  t.string :mpn
  t.boolean :active
  t.decimal :list_price
  t.decimal :sale_price
  t.integer :available_stock
  t.timestamps null: true
end

Product = Class.new(ActiveRecord::Base)

def create_products
  Product.create(name: "Book: The Good Neighbor", description: "From a phenomenal new voice in suspense fiction comes a book that will forever change the way you look at the people closest to you", active: true, list_price: 14.95, sale_price: 4.99, available_stock: 300)
  Product.create(name: "Book: The Hidden Child", description: "The brilliant new psychological thriller from worldwide bestseller Camilla Läckberg—the chilling struggle of a young woman facing the darkest chapter of Europe’s past.", active: false, list_price: 8.30, sale_price: 5.20, available_stock: 0)
  Product.create(name: "Thanth Womens Short Kimono Sleeve Boat Neck Dolman Top", description: "Simply design tunic dress which is basic but stylish.", active: true, list_price: 12.30, sale_price: 9.13, available_stock: 500)
end

def reindex_products
  Product.reindex
  Product.refresh_index
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:all) { create_products }

  config.after(:all) do
    Product.all.map(&:destroy)
    Product.delete_index
  end
end
