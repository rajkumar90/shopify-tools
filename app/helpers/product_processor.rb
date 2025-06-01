#!/usr/bin/env ruby

require "cgi"
require_relative "pricing_calculator"
require_relative "brand"

class ProductProcessor
  def initialize(brand_handle: nil)
    @brand_handle = brand_handle
  end

  def process_product(product)
    processed_variants = []

    # Handle multiple variants - each variant becomes a separate row
    product["variants"].each_with_index do |variant, variant_index|
      variant_data = build_variant_data(product, variant, variant_index)
      processed_variants << variant_data

      # Add additional image rows for this variant if product has multiple images
      additional_image_rows = build_additional_image_rows(product, variant_index)
      processed_variants.concat(additional_image_rows)
    end

    processed_variants
  end

  private

  def build_variant_data(product, variant, variant_index)
    {
      "Handle" => product["handle"],
      "Title" => build_title_with_brand(product["title"]),
      "Body (HTML)" => unescape_html(product["body_html"]),
      "Vendor" => product["vendor"],
      "Product Category" => "", # Simplified - no categorization
      "Type" => product["product_type"],
      "Tags" => @brand_handle || "", # Use brand handle instead of product tags
      "Published" => "FALSE",
      "Option1 Name" => get_option_name(product, 0),
      "Option1 Value" => variant["option1"],
      "Option2 Name" => get_option_name(product, 1),
      "Option2 Value" => variant["option2"],
      "Option3 Name" => get_option_name(product, 2),
      "Option3 Value" => variant["option3"],
      "Variant SKU" => variant["sku"],
      "Variant Grams" => variant["grams"],
      "Variant Inventory Tracker" => "shopify",
      "Variant Inventory Qty" => variant["available"] ? 100 : 0,
      "Variant Inventory Policy" => "deny",
      "Variant Fulfillment Service" => "manual",
      "Variant Price" => PricingCalculator.calculate_listing_price(variant["price"], variant["grams"]),
      "Variant Requires Shipping" => variant["requires_shipping"] ? "TRUE" : "FALSE",
      "Variant Taxable" => variant["taxable"] ? "TRUE" : "FALSE",
      "Variant Barcode" => "",
      "Image Src" => get_image_src(product, 0), # Always use first image for variant row
      "Image Position" => 1, # First image is always position 1
      "Image Alt Text" => product["title"],
      "Gift Card" => "FALSE",
      "SEO Title" => product["title"],
      "SEO Description" => generate_seo_description(product),
      "Google Shopping / Google Product Category" => "",
      "Google Shopping / Gender" => "",
      "Google Shopping / Age Group" => "",
      "Google Shopping / MPN" => variant["sku"],
      "Google Shopping / Condition" => "new",
      "Google Shopping / Custom Product" => "TRUE",
      "Variant Image" => get_variant_image(product, variant),
      "Variant Weight Unit" => "g",
      "Variant Tax Code" => "",
      "Cost per item" => variant["price"],
      "Included / India" => "TRUE",
      "Price / India" => PricingCalculator.calculate_listing_price(variant["price"], variant["grams"]),
      "Compare At Price / India" => variant["compare_at_price"],
      "Included / International" => "TRUE",
      "Price / International" => PricingCalculator.calculate_listing_price(variant["price"], variant["grams"]),
      "Compare At Price / International" => variant["compare_at_price"],
      "Status" => variant["available"] ? "active" : "draft"
    }
  end

  # Build additional image rows for products with multiple images
  # Following Shopify CSV format: https://help.shopify.com/en/manual/products/import-export/using-csv#adding-multiple-product-images
  def build_additional_image_rows(product, variant_index)
    images = product["images"]
    return [] if images.nil? || images.length <= 1

    additional_rows = []

    # Skip first image (already handled in main variant row) and create rows for remaining images
    # Only create additional image rows for the first variant to avoid duplicates
    return [] unless variant_index == 0

    images[1..-1].each_with_index do |image, index|
      additional_rows << build_image_only_row(product, image, index + 2) # Position starts from 2
    end

    additional_rows
  end

  # Create image-only row with minimal required fields
  def build_image_only_row(product, image, position)
    empty_csv_row.merge({
                          "Handle" => product["handle"],
                          "Image Src" => image["src"],
                          "Image Position" => position,
                          "Image Alt Text" => product["title"]
                        })
  end

  # Create empty CSV row with all fields set to empty strings
  def empty_csv_row
    {
      "Handle" => "",
      "Title" => "",
      "Body (HTML)" => "",
      "Vendor" => "",
      "Product Category" => "",
      "Type" => "",
      "Tags" => "",
      "Published" => "",
      "Option1 Name" => "",
      "Option1 Value" => "",
      "Option2 Name" => "",
      "Option2 Value" => "",
      "Option3 Name" => "",
      "Option3 Value" => "",
      "Variant SKU" => "",
      "Variant Grams" => "",
      "Variant Inventory Tracker" => "",
      "Variant Inventory Qty" => "",
      "Variant Inventory Policy" => "",
      "Variant Fulfillment Service" => "",
      "Variant Price" => "",
      "Variant Compare At Price" => "",
      "Variant Requires Shipping" => "",
      "Variant Taxable" => "",
      "Variant Barcode" => "",
      "Image Src" => "",
      "Image Position" => "",
      "Image Alt Text" => "",
      "Gift Card" => "",
      "SEO Title" => "",
      "SEO Description" => "",
      "Google Shopping / Google Product Category" => "",
      "Google Shopping / Gender" => "",
      "Google Shopping / Age Group" => "",
      "Google Shopping / MPN" => "",
      "Google Shopping / Condition" => "",
      "Google Shopping / Custom Product" => "",
      "Variant Image" => "",
      "Variant Weight Unit" => "",
      "Variant Tax Code" => "",
      "Cost per item" => "",
      "Included / India" => "",
      "Price / India" => "",
      "Compare At Price / India" => "",
      "Included / International" => "",
      "Price / International" => "",
      "Compare At Price / International" => "",
      "Status" => ""
    }
  end

  def build_title_with_brand(title)
    brand_name = get_brand_name
    return title if brand_name.nil? || brand_name.empty?

    "#{title} - #{brand_name}"
  end

  def get_brand_name
    return nil if @brand_handle.nil?

    brand = Brand::BRANDS.find { |b| b[:handle] == @brand_handle }
    brand&.dig(:name)
  end

  def unescape_html(html_string)
    return "" if html_string.nil?

    CGI.unescapeHTML(html_string)
  end

  def get_option_name(product, index)
    options = product["options"]
    return "" if options.nil? || options[index].nil?

    options[index]["name"]
  end

  def get_image_src(product, image_index)
    images = product["images"]
    return "" if images.nil? || images.empty?

    # Get specific image by index, fallback to first image
    image = images[image_index] || images.first
    image ? image["src"] : ""
  end

  def get_variant_image(product, variant)
    # Try to find variant-specific image
    images = product["images"]
    return "" if images.nil? || images.empty?

    # For now, just return the first image
    images.first["src"]
  end

  def generate_seo_description(product)
    html_body = unescape_html(product["body_html"])
    return "" if html_body.nil? || html_body.empty?

    # Strip HTML tags and extract first 160 characters for SEO
    plain_text = html_body.gsub(/<[^>]*>/, "").strip
    plain_text = plain_text.gsub(/\s+/, " ")

    if plain_text.length > 160
      plain_text[0..157] + "..."
    else
      plain_text
    end
  end
end
