#!/usr/bin/env ruby

require "csv"
require "fileutils"

class CsvGenerator
  SHOPIFY_CSV_HEADERS = [
    "Handle", "Title", "Body (HTML)", "Vendor", "Product Category", "Type", "Tags", "Published",
    "Option1 Name", "Option1 Value", "Option2 Name", "Option2 Value", "Option3 Name", "Option3 Value",
    "Variant SKU", "Variant Grams", "Variant Inventory Tracker", "Variant Inventory Qty",
    "Variant Inventory Policy", "Variant Fulfillment Service", "Variant Price", "Variant Compare At Price",
    "Variant Requires Shipping", "Variant Taxable", "Variant Barcode", "Image Src", "Image Position",
    "Image Alt Text", "Gift Card", "SEO Title", "SEO Description", "Google Shopping / Google Product Category",
    "Google Shopping / Gender", "Google Shopping / Age Group", "Google Shopping / MPN",
    "Google Shopping / Condition", "Google Shopping / Custom Product", "Variant Image",
    "Variant Weight Unit", "Variant Tax Code", "Cost per item", "Included / India", "Price / India",
    "Compare At Price / India", "Included / International", "Price / International",
    "Compare At Price / International", "Status"
  ].freeze

  def initialize(output_dir: "app/resources/products")
    @output_dir = output_dir
    ensure_output_directory_exists
  end

  def generate_csv(brand_handle, products_data)
    filename = generate_filename(brand_handle)

    if File.exist?(filename)
      append_new_variants(filename, products_data)
    else
      create_new_csv(filename, products_data)
    end

    filename
  end

  def generate_filename(brand_handle)
    # Brand handle is already sanitized, so use it directly
    File.join(@output_dir, "#{brand_handle}.csv")
  end

  private

  def append_new_variants(filename, new_variants_data)
    # Read existing handle+SKU combinations to avoid duplicates
    existing_variant_keys = read_existing_variant_keys(filename)

    # Filter out variants that already exist (based on Handle + Variant SKU combination)
    new_unique_variants = new_variants_data.reject do |variant|
      variant_key = generate_variant_key(variant["Handle"], variant["Variant SKU"])
      existing_variant_keys.include?(variant_key)
    end

    if new_unique_variants.empty?
      puts "  No new variants to add (all variants already exist in CSV)"
      return
    end

    # Append new variants to existing CSV
    CSV.open(filename, "a") do |csv|
      new_unique_variants.each do |variant|
        csv << SHOPIFY_CSV_HEADERS.map { |header| variant[header] }
      end
    end

    puts "  ✓ Appended #{new_unique_variants.length} new variants to existing CSV"
    puts "  ✓ Skipped #{new_variants_data.length - new_unique_variants.length} existing variants"
  end

  def create_new_csv(filename, products_data)
    CSV.open(filename, "w") do |csv|
      # Write header
      csv << SHOPIFY_CSV_HEADERS

      # Write data rows
      products_data.each do |product|
        csv << SHOPIFY_CSV_HEADERS.map { |header| product[header] }
      end
    end

    puts "  ✓ Created new CSV with #{products_data.length} variants"
  end

  def read_existing_variant_keys(filename)
    existing_variant_keys = Set.new

    CSV.foreach(filename, headers: true) do |row|
      handle = row["Handle"]
      variant_sku = row["Variant SKU"]

      # Create a unique key for each variant using handle and SKU
      if handle && !handle.strip.empty?
        variant_key = generate_variant_key(handle, variant_sku)
        existing_variant_keys.add(variant_key)
      end
    end

    existing_variant_keys
  rescue CSV::MalformedCSVError => e
    puts "  Warning: Error reading existing CSV (#{e.message}). Creating new file."
    Set.new
  end

  def generate_variant_key(handle, variant_sku)
    # Create a unique key combining handle and SKU
    # Handle case where SKU might be nil or empty
    sku_part = variant_sku.nil? || variant_sku.strip.empty? ? "NO_SKU" : variant_sku.strip
    "#{handle.strip}::#{sku_part}"
  end

  def ensure_output_directory_exists
    FileUtils.mkdir_p(@output_dir)
  end
end
