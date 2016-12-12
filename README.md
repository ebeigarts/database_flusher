# DatabaseFlusher

[![Build Status](https://travis-ci.org/ebeigarts/database_flusher.svg?branch=master)](https://travis-ci.org/ebeigarts/database_flusher)
[![Code Climate](https://codeclimate.com/github/ebeigarts/database_flusher/badges/gpa.svg)](https://codeclimate.com/github/ebeigarts/database_flusher)

database_flusher is a tiny and fast database cleaner inspired by [database_cleaner](https://github.com/DatabaseCleaner/database_cleaner) and [database_rewinder](https://github.com/amatsuda/database_rewinder).

## Features

* No monkey patching - uses `ActiveSupport::Notifications` and `Mongo::Monitoring::Global` to catch `INSERT` statements
* Fast `:deletion` strategy that cleans only tables/collections where `INSERT` statements were performed
* Faster `disable_referential_integrity` for PostgreSQL
* Executes multiple `DELETE` statements as one query with ActiveRecord

## Supported ORMs and strategies

| ORM          | Deletion | Transaction |
|:-------------|:---------|:------------|
| ActiveRecord | Yes      | Yes         |
| Mongoid      | Yes      | No          |


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'database_flusher'
```

And then execute:

```bash
$ bundle
```

## Usage

RSpec:

```ruby
RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before :suite do
    DatabaseFlusher[:active_record].strategy = :transaction
    DatabaseFlusher[:mongoid].strategy = :deletion
  end

  config.before :each do
    DatabaseFlusher[:active_record].strategy = :transaction
  end

  config.before :each, type: :feature do
    if Capybara.current_driver != :rack_test
      DatabaseFlusher[:active_record].strategy = :deletion
    end
  end

  config.before :each do
    DatabaseFlusher.start
  end

  config.append_after :each do
    DatabaseFlusher.clean
  end
end
```

Cucumber:

```ruby
DatabaseFlusher[:active_record].strategy = :transaction
DatabaseFlusher[:mongoid].strategy = :deletion

Before('~@javascript') do
  DatabaseFlusher[:active_record].strategy = :transaction
  DatabaseFlusher.start
end

Before('@javascript') do
  DatabaseFlusher[:active_record].strategy = :deletion
  DatabaseFlusher.start
end

After do
  DatabaseFlusher.clean
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ebeigarts/database_flusher. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
