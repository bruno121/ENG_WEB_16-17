class Client1

  require "socket"
  class Client
    def initialize( server )
      @server = server
      @request = nil
      @response = nil
      listen
      sends
      @request.join
      @response.join

    end

    def listen
      @response = Thread.new do
        loop {
          msg = @server.gets.chomp

          puts "#{msg}"
        }
      end
    end

    def sends
      id=2
      @request = Thread.new do
        @server.puts("ruido")
        loop {
          r=rand(0..1000)
           @server.puts("M,#{id},#{r},#{Time.now.ctime},ruido")
            sleep(30)
        }
      end
    end
  end

  server = TCPSocket.open( "127.0.0.1", 3000 )
  Client.new( server )
end