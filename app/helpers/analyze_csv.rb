#!/usr/bin/env ruby

require "csv"

def analyze_csv(filename)
  return unless File.exist?(filename)

  puts "Analyzing CSV file: #{filename}"
  puts "=" * 50

  data = CSV.read(filename, headers: true)

  puts "Total records: #{data.length}"
  puts "Total columns: #{data.headers.length}"
  puts

  # Analyze products
  unique_handles = data.map { |row| row["Handle"] }.uniq
  puts "Unique products: #{unique_handles.length}"
  puts

  # Analyze pricing
  prices = data.map { |row| row["Variant Price"].to_f }.select { |p| p > 0 }
  if prices.any?
    puts "Price range: ₹#{prices.min.round(2)} - ₹#{prices.max.round(2)}"
    puts "Average price: ₹#{(prices.sum / prices.length).round(2)}"
  end
  puts

  # Analyze categories
  categories = data.map { |row| row["Product Category"] }.uniq.compact
  puts "Product categories:"
  categories.each { |cat| puts "  - #{cat}" }
  puts

  # Show sample products
  puts "Sample products:"
  unique_handles.first(5).each do |handle|
    product_data = data.find { |row| row["Handle"] == handle }
    price = product_data["Variant Price"]
    puts "  - #{product_data['Title']} (₹#{price})"
  end

  puts
  puts "CSV analysis complete!"
end

# Run analysis
analyze_csv("app/resources/products/the_divine_foods.csv") if __FILE__ == $0
