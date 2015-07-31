# RailsSoftDeletable

[![Build Status](https://travis-ci.org/listia/rails_soft_deletable.svg?branch=master)](https://travis-ci.org/listia/rails_soft_deletable)

For changes/updates/history, please refer to [Github Releases](https://github.com/listia/rails_soft_deletable/releases).

This gem provides soft delete behavior to ActiveRecord 3.2.

## Installation

Add this line to your application's Gemfile:

    gem "rails_soft_deletable"

And then execute:

    $ bundle

## Usage

```ruby
class Company < ActiveRecord::Base
  soft_deletable
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
