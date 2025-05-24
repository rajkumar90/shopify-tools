# Shopify Tools

A Ruby on Rails application for Shopify integrations and tools.

## Requirements

* Ruby 3.3.0
* Rails 7.1.5.1
* SQLite3

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/shopify-tools.git
   cd shopify-tools
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   bin/rails db:setup
   ```

## Development

Start the Rails server:
```bash
make server
```

Or manually:
```bash
bin/rails server
```

## Testing

Run the tests:
```bash
make test
```

Or manually:
```bash
bin/rspec
```

## Linting

Check code style:
```bash
make lint-check
```

Fix code style issues:
```bash
make lint-fix
```

## Database Management

Reset the database:
```bash
make db-reset
```

## License

This project is available as open source under the terms of the MIT License.
