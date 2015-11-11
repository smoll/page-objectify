require "unparser"
require "page-objectify/ast_maker"
require "page-objectify/config"
require "page-objectify/logging"

module PageObjectify
  # Takes an Array of DOM elements
  # and generates Ruby code (page class containing PageObject::Accessors)
  class DOMToRuby
    include ASTMaker
    include Logging

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
        method_name = element[:id].downcase # because HTML ids are case-insensitive
        @config.method_name_mapping.each { |k,v| method_name.gsub!(k, v) }
        unless valid_method_name?(method_name)
          logger.warn "Final method name #{method_name} is not a valid Ruby method name! Stripping non-alpha characters as a last resort!"
          strip_non_alpha_or_underscore!(method_name)
        end

        res << s(:send, nil, element[:accessor].to_sym,
          s(:sym, method_name.to_sym),
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

    def valid_method_name?(s)
      # From http://stackoverflow.com/a/4379197
      !!(/\A(?:[a-z_]\w*[?!=]?|\[\]=?|<<|>>|\*\*|[!~+\*\/%&^|-]|[<>]=?|<=>|={2,3}|![=~]|=~)\z/i =~ s)
    end

    def strip_non_alpha_or_underscore!(m)
      m.gsub!(/[^a-z_]/, '')
    end
  end
end
