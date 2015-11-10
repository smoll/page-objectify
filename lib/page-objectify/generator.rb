require "nokogiri"
require "page-objectify/config"
require "page-objectify/dom"
require "page-objectify/dom_to_ruby"
require "page-objectify/logging"

module PageObjectify
  class Generator
    include Logging

    def initialize(**config)
      @config = Config.new(generator_class: self.class.to_s, **config)
    end

    # Calls #visit, generates a page class for the current page, then calls #teardown
    # Raises a NotImplementedError if #visit is not implemented
    # Raises a RuntimeError if @browser is not a Watir::Browser object
    def generate!
      raise NotImplementedError, "The #visit method does not exist! Please implement it!" unless respond_to?(:visit)
      visit
      execute_runtime_checks

      logger.info "About to parse HTML! Current URL: #{@browser.url}"

      doc = Nokogiri::HTML(@browser.html)
      @code = DOMToRuby.new(DOM.new(doc), @config).unparse

      logger.debug "** BEGIN GENERATED CODE **"
      @code.each_line { |line| logger.debug line.chomp }
      logger.debug "** END GENERATED CODE **"

      File.open(@config.file, 'w') { |file| file.write(@code) }

      teardown
    end

    def teardown
      @browser.quit
    end

    # Wait until the number of pending AJAX requests drops to zero. Assumes
    # jQuery is available on the page; behavior is undefined if it's not.
    #
    # Raises Watir::Wait::TimeoutError exception if timeout is exceeded.
    # Raises Selenium::WebDriver::Error::UnknownError: { "errorMessage":"Can't find variable: jQuery", ... } if jQuery is not loaded on page.
    def wait_for_ajax(timeout = 3, interval = 0.5)
      require "watir-webdriver/wait" unless defined?(Watir)
      (timeout / interval).to_i.times do
        return true if @browser.execute_script('return jQuery.active').to_i == 0
        sleep interval
      end

      raise Watir::Wait::TimeoutError, "Timeout of #{timeout} seconds exceeded on waiting for Ajax."
    end

    private

    def execute_runtime_checks
      fail "@browser variable must be a Watir::Browser instance! @browser=#{@browser.inspect}" unless @browser.is_a?(Watir::Browser)
      fail "Cannot get current page HTML!" unless @browser.respond_to?(:html)
    end
  end
end
