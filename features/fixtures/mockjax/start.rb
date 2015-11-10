#!/usr/bin/env ruby

if __FILE__ == $0
  require 'webrick'
  web_server = WEBrick::HTTPServer.new(:Port => 3001, :DocumentRoot => File.dirname(__FILE__))
  trap('INT') { web_server.shutdown }
  web_server.start
end
