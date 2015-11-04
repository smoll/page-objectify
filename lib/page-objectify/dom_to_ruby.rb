require "unparser"
require "page-objectify/ast_maker"
require "page-objectify/config"

module PageObjectify
  # Takes an Array of DOM nodes (Nokogiri::XML::Element objects)
  # and generates Ruby code (page class containing PageObject::Accessors)
  class DOMToRuby
    include ASTMaker

    def initialize(array, config)
      @array = array
      @config = config
    end

    # Generate Ruby source as a String
    def unparse
      # TODO: fix this
      node = s(:class,
        s(:const, nil, @config.page)
      )
      Unparser.unparse(node)
    end
  end
end
