require "nokogiri"

module PageObjectify
  class Generator
    def generate!
      after_navigation

      # Grab all nodes with non-empty HTML id
      @doc.xpath("//*[@id!='']").each do |node|
        puts "NODE: #{node}"
        @node_count += 1
      end

      puts "-" * 14
      puts "TOTAL NODES FOUND: #{@node_count}"
      puts "-" * 14
    end

    private

    def after_navigation
      fail "@browser variable must be a Watir::Browser instance! @browser=#{@browser.inspect}" unless @browser.is_a?(Watir::Browser)
      fail "@class must be a String! @class=#{@class.inspect}" unless @class.is_a?(String)
      fail "Cannot get current page HTML!" unless @browser.respond_to?(:html)
      @doc = Nokogiri::HTML(@browser.html)
      @node_count = 0
    end
  end
end
