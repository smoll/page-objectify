# page-objectify

A Ruby page class generator (for use with the page-object gem)

## Installation

Ensure this gem and watir-webdriver are both in your Gemfile:

```ruby
gem 'page-objectify'
gem 'watir-webdriver'
```

And then execute:

    $ bundle

## Usage

The supported usage of this gem is to:
* create a `SomethingPageGenerator` class that inherits from `PageObjectify::Generator`
* write a SomethingPageGenerator#generate method that navigates to the page you want to generate a page class for, before it calls #generate!
* initialize the generator class in some kind of Rake task (that is typically executed manually.)

Here's a complete example:

```ruby
# /generators/google_page_generator.rb
require "page-objectify/generator"
require "watir-webdriver"

class GooglePageGenerator < PageObjectify::Generator
  def generate
    @browser = Watir::Browser.new :chrome
    @browser.goto "www.google.com"
    # TODO: write a #wait_for_ajax helper
    sleep 1
    generate!
  ensure
    @browser.quit
  end
end
```

```ruby
# Rakefile
require "generators/google_page_generator"

namespace :po do
  task :generate do
    GooglePageGenerator.new(
      page: "GooglePage",
      base: "BasePage",
      file: "google_page.rb"
    ).generate
    # and any other pages you want to generate programmatically
  end
end
```

Then, upon executing the rake task `$ rake po:generate`, the following file will be generated (TODO!):

```ruby
class GooglePage < BasePage
  link(:xyz, id: 'xyz')
  button(:abc, id: 'abc')
  # etc.
end
```

Currently, only those HTML elements with a **non-empty id attribute** will have PageObject accessors generated for them.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/smoll/page-objectify.

