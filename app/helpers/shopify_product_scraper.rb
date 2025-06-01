#!/usr/bin/env ruby

require_relative "brand"
require_relative "shopify_api_client"
require_relative "product_processor"
require_relative "csv_generator"
require_relative "pricing_calculator"

class ShopifyProductScraper
  def initialize
    @csv_generator = CsvGenerator.new
  end

  def scrape_all_brands
    puts "=" * 80
    puts "Starting Shopify Product Scraper for All Brands"
    puts "=" * 80
    puts

    Brand::BRANDS.each do |brand|
      scrape_brand(brand)
      puts
    end

    puts "=" * 80
    puts "Scraping completed for all brands!"
    puts "=" * 80
  end

  def scrape_brand(brand)
    puts "Processing brand: #{brand[:name]}"
    puts "Brand handle: #{brand[:handle]}"
    puts "Best sellers URL: #{brand[:bestSellersUrl]}"
    puts "Pricing settings: #{PricingCalculator.pricing_summary}"
    puts "-" * 50

    # Parse URL to get base URL and collection path
    uri = URI(brand[:bestSellersUrl])
    base_url = "#{uri.scheme}://#{uri.host}"
    collection_path = uri.path

    # Initialize API client for this brand
    api_client = ShopifyApiClient.new(base_url)

    # Fetch all products across all pages
    all_products = api_client.fetch_all_products(collection_path)

    if all_products.empty?
      puts "No products found for #{brand[:name]}"
      return
    end

    # Initialize product processor with brand handle
    product_processor = ProductProcessor.new(brand_handle: brand[:handle])

    # Process all products and calculate statistics
    puts "Processing #{all_products.length} products..."
    all_csv_rows = []
    total_variants = 0
    total_images = 0

    all_products.each do |product|
      csv_rows = product_processor.process_product(product)
      all_csv_rows.concat(csv_rows)

      # Count actual variants and images
      product_variants = product["variants"]&.length || 0
      product_images = product["images"]&.length || 0

      total_variants += product_variants
      total_images += product_images
    end

    if all_csv_rows.empty?
      puts "No CSV data to process for #{brand[:name]}"
      return
    end

    # Calculate CSV row breakdown
    variant_rows = all_csv_rows.count { |row| !row["Title"].empty? }
    image_rows = all_csv_rows.count { |row| row["Title"].empty? }

    # Check if CSV already exists
    csv_filename = @csv_generator.generate_filename(brand[:handle])
    csv_exists = File.exist?(csv_filename)

    puts "CSV Status: #{csv_exists ? 'Existing file found - will check for new variants to append' : 'New file will be created'}"

    # Generate CSV (append or create new)
    output_file = @csv_generator.generate_csv(brand[:handle], all_csv_rows)

    puts "✓ CSV file: #{output_file}"
    puts "✓ Statistics:"
    puts "  - Products: #{all_products.length}"
    puts "  - Total variants: #{total_variants}"
    puts "  - Total images: #{total_images}"
    puts "  - CSV rows created:"
    puts "    • Variant rows: #{variant_rows}"
    puts "    • Additional image rows: #{image_rows}"
    puts "    • Total CSV rows: #{all_csv_rows.length}"
    puts "✓ Brand handle used: #{brand[:handle]}"

    # Show pricing example
    show_pricing_example(all_csv_rows.find { |row| !row["Title"].empty? }) if all_csv_rows.any?
  end

  private

  def show_pricing_example(sample_variant)
    return unless sample_variant

    puts
    puts "Pricing Example:"
    puts "  Product: #{sample_variant['Title']}"
    puts "  Original Price: ₹#{sample_variant['Cost per item']}"
    puts "  Final Price: ₹#{sample_variant['Variant Price']}"
    puts "  Weight: #{sample_variant['Variant Grams']}g"
    puts "  Handle: #{sample_variant['Tags']}"
  end
end

# Main execution
if __FILE__ == $0
  scraper = ShopifyProductScraper.new
  scraper.scrape_all_brands
end
