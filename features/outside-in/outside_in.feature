@announce-output
Feature: outside-in
  * Must be in a separate subdir than the other .feature files, otherwise env.rb may mask issues!

  Scenario: valid, use Gemfile
    Given I set the environment variables to:
      | variable       | value        |
      | BUNDLE_GEMFILE | Gemfile.test |
    And a file named "Gemfile.test" with:
    """ruby
    source "https://rubygems.org"

    gem "page-objectify", :path => "../.."
    gem "phantomjs"
    gem "rake"
    gem "watir-webdriver"
    """
    And a file named "outie_page_generator.rb" with:
    """ruby
    puts "LOAD_PATH=#{$LOAD_PATH.join(',\n')}"

    require "page-objectify/generator"
    require "phantomjs"

    class OutiePageGenerator < PageObjectify::Generator
      def visit
        Selenium::WebDriver::PhantomJS.path = Phantomjs.path
        @browser = Watir::Browser.new :phantomjs
        @browser.goto 'data:text/html,<h1 id="heading">Hello World</h1><form action="action_page.php">First name:<br><input type="text" name="firstname" id="firstname" value="Mickey"><br>Last name:<br><input type="text" name="lastname" id="lastname" value="Mouse"><br><br><input type="submit" id="submit-it" value="Submit"></form>'
      end
    end
    """
    And a file named "Rakefile" with:
    """ruby
    require_relative "outie_page_generator"

    task :outie do
      OutiePageGenerator.new.generate!
    end
    """
    When I run `bundle exec rake outie`
    Then the output should not contain:
    """
    rake aborted!
    """
    Then the file "outie_page.rb" should contain:
    """
    # This code was generated by calling:
    # OutiePageGenerator.new.generate!
    """
    And the file "outie_page.rb" should contain:
    """
    # Note that changes to the underlying page that this page class is modeling, or
    # new versions of PageObjectify, may require this file to be generated again.
    class OutiePage < BasePage
      text_field(:firstname, id: "firstname")
      h1(:heading, id: "heading")
      text_field(:lastname, id: "lastname")
      button(:submitit, id: "submit-it")
    end
    """
