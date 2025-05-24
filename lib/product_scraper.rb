#!/usr/bin/env ruby

require "csv"
require "json"

class ProductScraper
  def initialize
    @products = []
  end

  def scrape_divine_foods_content(content)
    # For this dry run, we'll extract the first product manually from the content
    # Based on the website content provided, extracting the Palm Jaggery product

    product = {
      name: "100% Pure, Natural and Unrefined Palm Jaggery (Karupatti) 500 gm",
      sale_price: "Rs. 294.00",
      regular_price: "Rs. 480.00",
      reviews_count: "193",
      description: "NATURAL SUGAR ALTERNATIVE: This unrefined \"The Divine Foods\" coconut blossom sugar can be used instead...",
      availability: "Sold Out",
      category: "Natural Sweeteners",
      source_url: "https://www.thedivinefoods.com/collections/all"
    }

    @products << product
    puts "✅ Scraped 1 product: #{product[:name]}"

    product
  end

  def save_to_csv(filename = "divine_foods_products.csv")
    CSV.open(filename, "w", headers: true) do |csv|
      # Write headers
      csv << ["Name", "Sale Price", "Regular Price", "Reviews Count", "Description", "Availability", "Category",
              "Source URL"]

      # Write product data
      @products.each do |product|
        csv << [
          product[:name],
          product[:sale_price],
          product[:regular_price],
          product[:reviews_count],
          product[:description],
          product[:availability],
          product[:category],
          product[:source_url]
        ]
      end
    end

    puts "💾 Saved #{@products.length} product(s) to #{filename}"
    puts "📄 CSV file created successfully!"
  end

  def run_dry_run
    puts "🚀 Starting product scraper dry run for The Divine Foods..."
    puts "🎯 Target: Extract 1 product only"
    puts "=" * 50

    # Sample content (this would normally come from web scraping)
    content = "Sample website content for dry run"

    # Scrape the content
    product = scrape_divine_foods_content(content)

    # Save to CSV
    save_to_csv

    puts "=" * 50
    puts "✨ Dry run completed successfully!"
    puts "📊 Product extracted:"
    puts "   Name: #{product[:name]}"
    puts "   Sale Price: #{product[:sale_price]}"
    puts "   Regular Price: #{product[:regular_price]}"
    puts "   Reviews: #{product[:reviews_count]}"
    puts "   Status: #{product[:availability]}"
  end
end

# Run the dry run if this file is executed directly
if __FILE__ == $0
  scraper = ProductScraper.new
  scraper.run_dry_run
end
