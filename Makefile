.PHONY: server test lint-check lint-fix scrape-products scrape-shopify-json analyze-csv

server:
	bin/rails server

test:
	bin/rspec

console:
	bin/rails console

lint-check:
	bundle exec rubocop

lint-fix:
	bundle exec rubocop -a

routes:
	bin/rails routes

db-migrate:
	bin/rails db:migrate

db-seed:
	bin/rails db:seed

db-reset:
	bin/rails db:drop db:create db:migrate db:seed 

scrape-products:
	ruby app/helpers/shopify_product_scraper.rb

scrape-shopify-json:
	ruby app/helpers/shopify_product_scraper.rb

analyze-csv:
	ruby app/helpers/analyze_csv.rb 