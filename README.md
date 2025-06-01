# Shopify Tools

A Rails application for scraping and processing product data for Shopify imports with support for multiple brands and pagination.

## Overview

This project provides tools to scrape product data from various Shopify stores and convert them into Shopify-compatible CSV formats. The application is built with a modular architecture for easy maintenance and extensibility.

## Features

### Multi-Brand Support
- Process multiple brands from a centralized configuration
- Individual CSV files generated per brand
- Flexible brand configuration with custom URLs

### Shopify Product Scraper
- Fetches real-time product data from Shopify JSON APIs
- **Pagination Support**: Automatically fetches all products across multiple pages
- Applies custom pricing logic (profit margins, shipping costs)
- Handles multi-variant products
- Generates SEO-friendly descriptions

### Modular Architecture
- **ShopifyProductScraper**: Main orchestrator for multi-brand processing
- **ShopifyApiClient**: Handles API requests with pagination support
- **ProductProcessor**: Processes individual products and variants  
- **CsvGenerator**: Generates Shopify-compatible CSV files with variant-level duplicate detection
- **PricingCalculator**: Utility class for pricing calculations with default values

## Quick Start

### Prerequisites
- Ruby 3.x
- Rails 7.x
- Bundler

### Installation
```bash
bundle install
```

### Usage

#### Scrape All Brands with Pagination
```bash
# Using Makefile (recommended)
make scrape-shopify-json

# Or directly
ruby app/helpers/shopify_product_scraper.rb
```

This will:
1. Read all brands from `app/helpers/brand.rb`
2. For each brand, fetch products from their `bestSellersUrl`
3. Use pagination (page=1,2,3... limit=50) to get ALL products
4. Process and apply pricing logic to each variant
5. Generate individual CSV files for each brand

#### Analyze Generated CSV
```bash
make analyze-csv
```

#### Available Make Commands
```bash
make server           # Start Rails server
make test            # Run RSpec tests
make lint-check      # Run RuboCop linter
make lint-fix        # Auto-fix RuboCop issues
make scrape-shopify-json  # Run Shopify product scraper (with pagination)
make analyze-csv     # Analyze generated CSV
```

## Configuration

### Brand Configuration
Edit `app/helpers/brand.rb` to add new brands:

```ruby
module Brand
  BRANDS = [
    {
      name: "The Divine Foods",
      tag: "divine-foods",
      url: "https://www.thedivinefoods.com/",
      bestSellersUrl: "https://www.thedivinefoods.com/collections/best-sellers",
      allProductsUrl: "https://www.thedivinefoods.com/collections/all"
    }
    # Add more brands here
  ].freeze
end
```

### Pricing Configuration
The scraper uses these default pricing settings (configurable in `PricingCalculator` constants):
- Profit margin: 40%
- Shipping cost: ₹1800 per kg
- Customs fees: ₹0

To modify pricing, edit the constants in `app/helpers/pricing_calculator.rb`:
```ruby
PROFIT_MARGIN_PERCENT = 40
CUSTOMS = 0
SHIPPING_PRICE_PER_KG = 1800
```

## File Structure

### Core Classes
- `app/helpers/shopify_product_scraper.rb` - Main orchestrator
- `app/helpers/shopify_api_client.rb` - API client with pagination
- `app/helpers/product_processor.rb` - Product processing logic
- `app/helpers/csv_generator.rb` - CSV generation
- `app/helpers/pricing_calculator.rb` - Pricing utility class
- `app/helpers/analyze_csv.rb` - CSV analysis utility

### Configuration
- `app/helpers/brand.rb` - Brand definitions

### Output
- `app/resources/products/` - Generated CSV files (one per brand)
- `app/resources/product_template.csv` - Shopify CSV template

## Key Features

### Pagination Support
The scraper automatically handles pagination:
- Starts with page=1, limit=50
- Continues fetching until no more products are returned
- Processes ALL products across ALL pages
- Provides detailed logging of pagination progress

### Pricing Logic
Each product variant gets custom pricing using the utility method:
```ruby
PricingCalculator.calculate_listing_price(original_price, weight_grams)
```

Formula:
```
listing_price = original_price + weight_in_kgs * shipping_price_per_kg + customs + original_price * (profit_margin_percent / 100)
```

### Multi-Variant Support
- Each product variant becomes a separate CSV row
- Handles complex products with multiple options (size, color, etc.)
- Maintains proper Shopify CSV structure

### Intelligent Duplicate Detection
- **Variant-Level Uniqueness**: Uses combination of `Handle` + `Variant SKU` for duplicate detection
- **Smart Merging**: When re-running the scraper, only new variants are added to existing CSVs
- **No Data Loss**: Existing variants are preserved while new variants are appended
- **Edge Case Handling**: Properly handles empty/nil SKUs using "NO_SKU" placeholder

#### How It Works
When the scraper runs multiple times:

1. **First Run**: Creates CSV with all variants
   ```
   Handle: awesome-tshirt, SKU: TSH-001-S (Small)
   Handle: awesome-tshirt, SKU: TSH-001-M (Medium)
   ```

2. **Second Run**: Product now has new variants
   ```
   Input: TSH-001-S (Small), TSH-001-M (Medium), TSH-001-L (Large), TSH-001-XL (XL)
   Result: Only TSH-001-L and TSH-001-XL are added to CSV
   ```

3. **Benefits**:
   - ✅ Existing variants are not duplicated
   - ✅ New variants are automatically detected and added
   - ✅ Works even when products have the same handle
   - ✅ Preserves all existing data integrity

#### Example Usage
```ruby
# Demo script available at: examples/variant_uniqueness_demo.rb
ruby examples/variant_uniqueness_demo.rb
```

## Testing

```bash
# Run all tests
make test

# Run specific test
bin/rspec spec/path/to/test_spec.rb
```

## Linting

```bash
# Check for style issues
make lint-check

# Auto-fix style issues
make lint-fix
```

## Architecture Benefits

1. **Modular Design**: Each class has a single responsibility
2. **Easy Testing**: Small, focused classes are easier to test
3. **Extensible**: Easy to add new brands or pricing rules
4. **Pagination**: Handles large catalogs automatically
5. **Error Resilient**: Proper error handling at each layer
6. **Multi-Brand**: Process multiple brands from single command
7. **Simplified Configuration**: Utility classes with sensible defaults

## Documentation

For detailed documentation on the Shopify product scraper, see:
`lib/shopify_json_scraper.md`
