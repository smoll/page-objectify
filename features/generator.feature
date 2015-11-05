Feature: generate

  Scenario: from fake page
    Given a file named "fake_page_generator.rb" with:
    """ruby
    require "page-objectify"
    require "page-objectify/generator"
    require "phantomjs"
    require "watir-webdriver"

    class FakePageGenerator < PageObjectify::Generator
      def generate
        Selenium::WebDriver::PhantomJS.path = Phantomjs.path
        @browser = Watir::Browser.new :phantomjs
        @browser.goto 'data:text/html,<h1 id="heading">Hello World</h1><form action="action_page.php">First name:<br><input type="text" name="firstname" id="firstname" value="Mickey"><br>Last name:<br><input type="text" name="lastname" id="lastname" value="Mouse"><br><br><input type="submit" id="submit" value="Submit"></form>'
        generate!
      ensure
        @browser.quit
      end
    end
    """
    And a file named "Rakefile" with:
    """ruby
    require_relative "fake_page_generator"

    task :fake do
      FakePageGenerator.new.generate
    end
    """
    When I run `rake fake`
    Then the output should not contain:
    """
    rake aborted!
    """
    Then the file "fake_page.rb" should contain:
    """
    class FakePage < BasePage
      heading(:heading, id: "heading")
      text_field(:firstname, id: "firstname")
      text_field(:lastname, id: "lastname")
      button(:submit, id: "submit")
    end
    """
