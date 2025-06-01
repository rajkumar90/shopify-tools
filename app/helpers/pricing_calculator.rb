#!/usr/bin/env ruby

class PricingCalculator
  # Default pricing configuration
  PROFIT_MARGIN_PERCENT = 40
  CUSTOMS = 0
  SHIPPING_PRICE_PER_KG = 1800

  def self.calculate_listing_price(original_price_str, weight_grams)
    return original_price_str if original_price_str.nil? || original_price_str.empty?

    original_price = original_price_str.to_f
    weight_in_kgs = weight_grams.to_f / 1000.0

    shipping_cost = weight_in_kgs * SHIPPING_PRICE_PER_KG
    profit_margin = original_price * (PROFIT_MARGIN_PERCENT / 100.0)

    listing_price = original_price + shipping_cost + CUSTOMS + profit_margin

    format("%.2f", listing_price)
  end

  def self.pricing_summary
    {
      profit_margin_percent: PROFIT_MARGIN_PERCENT,
      customs: CUSTOMS,
      shipping_price_per_kg: SHIPPING_PRICE_PER_KG
    }
  end
end
