require "unparser"
require "page-objectify/ast_maker"
require "page-objectify/config"

module PageObjectify
  # Takes an Array of DOM elements
  # and generates Ruby code (page class containing PageObject::Accessors)
  class DOMToRuby
    include ASTMaker

    def initialize(dom, config)
      @dom = dom
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
      @dom.to_accessors.each do |element|
        res << s(:send, nil, element[:accessor].to_sym,
          s(:sym, element[:id].gsub("-", "_").to_sym), # Can't have dashes in method names!
          s(:hash,
            s(:pair,
              s(:sym, :id),
              s(:str, element[:id])
            )
          )
        )
      end
      res
    end
  end
end
