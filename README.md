# page-objectify

[![Build Status](https://travis-ci.org/smoll/page-objectify.svg)](https://travis-ci.org/smoll/page-objectify)

A Ruby [page class](https://github.com/cheezy/page-object/wiki/Get-me-started-right-now!#describe-your-page) generator (for use with the page-object gem)

## Why?

Normally, I’d advise against using a gem like this, because the page class shouldn't necessarily contain methods for every single HTML element on the page. In fact, if the page we are modeling is anything like the Google home page, our page class should only have one or 2 methods (a.k.a. [PageObject::Accessors](http://www.rubydoc.info/github/cheezy/page-object/PageObject/Accessors)) for HTML elements: the search box and the submit button.

However, recently, almost all of the tests I have been writing have been for non-public facing sites, used by specialized, internal users who are trained on the platform. As a result, we end up with fairly dense webpages, with multiple different features and HTML elements that need interacting with, all on a single page.

Ultimately, this is the specific use case I am writing this gem for. Also, I wanted to learn a bit more about how a Ruby AST -- abstract syntax tree -- works and how the unparser gem allows me to generate working Ruby code from a dynamically generated AST.

## Changes

This gem will follow semantic versioning. See [changelog](./CHANGELOG.md) for changes in each version.

## Installation

Ensure this gem and watir-webdriver are both in your Gemfile:

```ruby
gem "page-objectify"
gem "watir-webdriver"
```

And then execute:

    $ bundle

## Usage

The supported usage of this gem is to:
* create a `SomethingPageGenerator` class that inherits from `PageObjectify::Generator`
* write a `SomethingPageGenerator#visit` method that opens a browser and navigates to the page you want to generate a page class for.
* initialize the generator class & call `#generate!` in some kind of Rake task (that is typically executed manually.)

Here's a complete example (using the Google homepage, which, as I mention above, is a [horrible use case](#why), but it works for a demo):

```ruby
# Gemfile
gem "chromedriver-helper", "~> 1.0"
gem "page-objectify"
gem "watir-webdriver", "~> 0.9.1"
```

```ruby
# /generators/google_page_generator.rb
require "page-objectify/generator"
require "watir-webdriver"

class GooglePageGenerator < PageObjectify::Generator
  # Overriding the constructor here is optional
  def initialize
    super(file: "path/to/pages-dir/google_page.rb")
  end

  def visit
    @browser = Watir::Browser.new :chrome
    @browser.goto "www.google.com"
    sleep 1 # Use `wait_for_ajax` instead of `sleep`, if jQuery is available on the page!
  end
end
```

```ruby
# Rakefile
require "generators/google_page_generator"

namespace :po do
  task :generate do
    GooglePageGenerator.new.generate!
    # and any other pages you want to generate programmatically
  end
end
```

Then, upon executing the rake task `$ bundle exec rake po:generate`, the following file will be generated:

```ruby
class GooglePage < BasePage
  div(:viewport, id: "viewport")
  div(:"doc-info", id: "doc-info")
  div(:cst, id: "cst")
  text_area(:csi, id: "csi")
  div(:searchform, id: "searchform")
  # etc.
end
```

Currently, only those HTML elements with a **non-empty id attribute** will have PageObject accessors generated for them.

For another example (using watir-webdriver and phantomjs via the `phantomjs` gem), see [this integration test](features/generator.feature).

## Debugging & Development

The default log level is `2`. Set this to a lower level to see helpful DEBUG level prints, i.e.

```ruby
PageObjectify::Logging.logger.level = 0
```

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/smoll/page-objectify.

