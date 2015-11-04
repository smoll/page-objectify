require "unparser"
require "page-objectify/ast_maker"

module PageObjectify
  # Takes an Array of DOM nodes (Nokogiri::XML::Element objects)
  # and generates Ruby code (page class containing PageObject::Accessors)
  class DOMToRuby
    include ASTMaker

    def initialize(array)
      @array = array
    end

    # Generate Ruby source as a String
    def unparse
      # TODO: replace this with real stuff
      node = s(:class,
        s(:const, nil, :GooglePage)
      )
      Unparser.unparse(node)
    end
  end
end
