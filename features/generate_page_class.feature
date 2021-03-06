Feature: generate page class

  Scenario: invalid generator
    Given a file named "invalid_generator.rb" with:
    """ruby
    require "page-objectify/generator"
    require "phantomjs"
    require "watir-webdriver"

    class InvalidGenerator < PageObjectify::Generator
      # because we didn't create a #visit method
    end
    """
    And a file named "Rakefile" with:
    """ruby
    require_relative "invalid_generator"

    task :invalid do
      InvalidGenerator.new.generate!
    end
    """
    When I run `rake invalid`
    Then the output should contain:
    """
    The #visit method does not exist! Please implement it!
    """

  Scenario: valid page class & code comment banner with timestamp
    Given a file named "fake_page_generator.rb" with:
    """ruby
    require "page-objectify/generator"
    require "phantomjs"
    require "watir-webdriver"

    class FakePageGenerator < PageObjectify::Generator
      def visit
        Selenium::WebDriver::PhantomJS.path = Phantomjs.path
        @browser = Watir::Browser.new :phantomjs
        @browser.goto 'data:text/html,<h1 id="heading">Hello World</h1><form action="action_page.php">First name:<br><input type="text" name="firstname" id="firstname" value="Mickey"><br>Last name:<br><input type="text" name="lastname" id="lastname" value="Mouse"><br><br><input type="submit" id="submit-it" value="Submit"></form>'
      end
    end
    """
    And a file named "Rakefile" with:
    """ruby
    require_relative "fake_page_generator"

    task :fake do
      FakePageGenerator.new.generate!
    end
    """
    When I run `rake fake`
    Then the output should not contain:
    """
    rake aborted!
    """
    Then the file "fake_page.rb" should contain:
    """
    # This code was generated by calling:
    # FakePageGenerator.new.generate!
    """
    # "# on #{Time.now} using PageObjectify version #{PageObjectify::VERSION}."
    # is left out because there's no way to know this String ahead of time in
    # the .feature file (Timecop doesn't work because the generator runs in
    # a different process)
    And the file "fake_page.rb" should contain:
    """
    # Note that changes to the underlying page that this page class is modeling, or
    # new versions of PageObjectify, may require this file to be generated again.
    class FakePage < BasePage
      text_field(:firstname, id: "firstname")
      h1(:heading, id: "heading")
      text_field(:lastname, id: "lastname")
      button(:submitit, id: "submit-it")
    end
    """

  @mockjax
  Scenario: page with mock AJAX
    Given a file named "mockjax_page_generator.rb" with:
    """ruby
    require "page-objectify/generator"
    require "phantomjs"
    require "watir-webdriver"

    class MockjaxPageGenerator < PageObjectify::Generator
      def visit
        Selenium::WebDriver::PhantomJS.path = Phantomjs.path
        @browser = Watir::Browser.new :phantomjs
        @browser.goto "http://localhost:3001" # See fixtures/mockjax/start.rb
        wait_for_ajax # See fixtures/mockjax/index.html, 1500 ms delay on AJAX
      end
    end
    """
    And a file named "Rakefile" with:
    """ruby
    require_relative "mockjax_page_generator"

    task :mockjax do
      MockjaxPageGenerator.new.generate!
    end
    """
    When I run `rake mockjax`
    Then the output should not contain:
    """
    rake aborted!
    """
    Then the file "mockjax_page.rb" should contain:
    """
    class MockjaxPage < BasePage
      div(:content, id: "content")
    end
    """

  @announce-output
  Scenario: with mapping
    Given a file named "mapping_page_generator.rb" with:
    """ruby
    require "page-objectify/generator"
    require "phantomjs"
    require "watir-webdriver"

    class MappingPageGenerator < PageObjectify::Generator
      def visit
        Selenium::WebDriver::PhantomJS.path = Phantomjs.path
        @browser = Watir::Browser.new :phantomjs
        @browser.goto 'data:text/html,<h1 id="1Heading">Hello World</h1><form action="action_page.php">First name:<br><input type="text" name="firstname" id="first-name-ok" value="Mickey"><br>Last name:<br><input type="text" name="lastname" id="last:name" value="Mouse"><br><br><input type="submit" id="Submit" value="Submit"></form>'
      end
    end
    """
    And a file named "Rakefile" with:
    """ruby
    require_relative "mapping_page_generator"

    MAPPING = { /^(\d+)/ => 'x_\1', "-" => "_", ":" => "_" }

    task :mapping do
      MappingPageGenerator.new(method_name_mapping: MAPPING).generate!
    end
    """
    When I run `rake mapping`
    Then the output should not contain:
    """
    rake aborted!
    """
    # Expected behavior:
    # 1) regex mapping prepends leading number with "x_"
    # 2) string mapping converts dashes to underscores
    # 3) string mapping converts colons to underscores
    # 4) downcase without needing mapping for that
    And the file "mapping_page.rb" should contain:
    """
    class MappingPage < BasePage
      text_field(:first_name_ok, id: "first-name-ok")
      text_field(:last_name, id: "last:name")
      button(:submit, id: "Submit")
      h1(:x_1heading, id: "1Heading")
    end
    """
