require "aruba/cucumber"
require "socket"
require "timeout"
require "pathname"

def is_port_open?(host, port, timeout = 5, sleep_period = 0.1)
  begin
    Timeout::timeout(timeout) do
      begin
        s = TCPSocket.new(host, port)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        sleep(sleep_period)
        retry
      end
    end
  rescue Timeout::Error
    return false
  end
end

Before("@mockjax") do
  start_server = Pathname.new(__dir__).parent.join("fixtures", "mockjax", "start.rb")
  @server = IO.popen("ruby #{start_server}", "r") # Start server
  mockjax_host = "127.0.0.1"
  mockjax_port = 3001 # See fixtures/mockjax/start.rb
  is_port_open?(mockjax_host, mockjax_port) # Block until server starts
end

After("@mockjax") { Process.kill("KILL", @server.pid) } # Stop server
