# Product Scraper for The Divine Foods

## Overview
Simple Ruby script to scrape product information from [The Divine Foods](https://www.thedivinefoods.com/collections/all) website and export to CSV format.

## Features
- ✅ Extracts product details (name, prices, reviews, descriptions)
- 📊 Exports data to CSV format
- 🎯 Currently configured for dry run with 1 product
- 🚀 Simple execution via Makefile

## Usage

### Method 1: Using Makefile (Recommended)
```bash
make scrape-products
```

### Method 2: Direct Ruby execution
```bash
ruby lib/product_scraper.rb
```

## Output
The scraper creates a `divine_foods_products.csv` file with the following columns:
- Name
- Sale Price
- Regular Price
- Reviews Count
- Description
- Availability
- Category
- Source URL

## Sample Output
```csv
Name,Sale Price,Regular Price,Reviews Count,Description,Availability,Category,Source URL
"100% Pure, Natural and Unrefined Palm Jaggery (Karupatti) 500 gm",Rs. 294.00,Rs. 480.00,193,"NATURAL SUGAR ALTERNATIVE: This unrefined ""The Divine Foods"" coconut blossom sugar can be used instead...",Sold Out,Natural Sweeteners,https://www.thedivinefoods.com/collections/all
```

## Current Implementation
- **Dry Run Mode**: Currently extracts 1 hardcoded product for testing
- **No External Dependencies**: Uses only Ruby standard library (CSV)
- **Simple Structure**: No models or database persistence

## Future Enhancements
- Web scraping with Nokogiri or HTTParty
- Multiple product extraction
- Error handling for network requests
- Product categorization
- Image URL extraction
- Price comparison features

## Files
- `lib/product_scraper.rb` - Main scraper implementation
- `divine_foods_products.csv` - Generated output file
- `lib/product_scraper.md` - This documentation 