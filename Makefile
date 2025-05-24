.PHONY: server test lint-check lint-fix scrape-products

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
	ruby lib/product_scraper.rb 