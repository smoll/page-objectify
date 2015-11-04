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
      tree = s(:class,
        *first_line,
        s(:send, nil, :link,
          s(:sym, :abc),
          s(:hash,
            s(:pair,
              s(:sym, :id),
              s(:str, "abc")
            )
          )
        )
      )
      Unparser.unparse(tree)
    end

    private

    # Array of Parser::AST::Nodes, which represents the line:
    # "GeneratedPage < BasePage"
    def first_line
      [s(:const, nil, @config.page), s(:const, nil, @config.base)]
    end
  end
end
