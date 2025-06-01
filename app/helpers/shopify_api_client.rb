#!/usr/bin/env ruby

require "net/http"
require "json"
require "uri"

class ShopifyApiClient
  def initialize(base_url)
    @base_url = base_url
  end

  def fetch_all_products(collection_path)
    all_products = []
    page = 1
    limit = 50

    loop do
      puts "Fetching page #{page}..."

      products = fetch_products_page(collection_path, page, limit)
      break if products.nil? || products.empty?

      all_products.concat(products)
      puts "Fetched #{products.length} products from page #{page}"

      # If we got fewer products than the limit, we've reached the end
      break if products.length < limit

      page += 1
    end

    puts "Total products fetched: #{all_products.length}"
    all_products
  end

  private

  def fetch_products_page(collection_path, page, limit)
    endpoint = "#{collection_path}/products.json"
    uri = URI("#{@base_url}#{endpoint}")

    # Add query parameters
    params = {
      "page" => page.to_s,
      "limit" => limit.to_s
    }
    uri.query = URI.encode_www_form(params)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 30

    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    request["Accept"] = "application/json"

    begin
      response = http.request(request)

      if response.code == "200"
        json_data = JSON.parse(response.body)
        json_data["products"] || []
      else
        puts "Failed to fetch page #{page}: #{response.code} #{response.message}"
        nil
      end
    rescue StandardError => e
      puts "Error fetching page #{page}: #{e.message}"
      nil
    end
  end
end
