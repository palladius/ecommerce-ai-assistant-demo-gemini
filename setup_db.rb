require "bundler/setup"
Bundler.require
require "dotenv/load"

DB = Sequel.sqlite(ENV["DATABASE_NAME"])

DB.create_table :products do
  String :sku, primary_key: true
  Float :price
  Integer :quantity
  String :name
end

DB.create_table :orders do
  primary_key :id
  Integer :customer_id
  DateTime :created_at
end

DB.create_table :order_items do
  primary_key :id
  foreign_key :order_id, :orders, on_delete: :cascade
  foreign_key :product_sku, :products, type: String, key: :sku
  Integer :quantity
end

DB.create_table :customers do
  primary_key :id
  String :name
  String :email
end

products = DB[:products]
products.insert sku: 'A3045809', price: 20.99, quantity: 100,name: 'T-shirt'
products.insert sku: 'B9384509', price: 21.99, quantity: 5,  name: 'Nerdy T-shirt'
products.insert sku: 'Z0394853', price: 22.99, quantity: 20, name: 'Coffee Mug'
products.insert sku: 'X3048509', price: 23.99, quantity: 3,  name: 'Bosnian GOAT'
products.insert sku: 'Y3048509', price: 24.99, quantity: 10, name: 'T-shirt'
products.insert sku: 'L3048509', price: 29.99, quantity: 0,  name: 'T-shirt'


customers = DB[:customers]
customers.insert name: 'Riccardo Carlesso', email: 'riccardo.carlesso@gmail.com'
customers.insert name: 'Andrei Bondarev', email: 'andrei@sourcelabs.io'
