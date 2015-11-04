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
      tree = s(:class,
        *first_line,
        s(:begin, *accessors)
      )
      Unparser.unparse(tree)
    end

    private

    # Array of Parser::AST::Nodes, which represents the line:
    # "GeneratedPage < BasePage"
    def first_line
      [s(:const, nil, @config.page), s(:const, nil, @config.base)]
    end

    # Array of AST nodes, which represent lines that look like:
    # button(:submit, id: "submit")
    # button(:cancel, id: "cancel")
    def accessors
      res = []
      @array.each do |element|
        res << s(:send, nil, :link,
          s(:sym, element.attributes["id"].to_s.to_sym),
          s(:hash,
            s(:pair,
              s(:sym, :id),
              s(:str, element.attributes["id"].to_s)
            )
          )
        )
      end
      res
    end
  end
end
