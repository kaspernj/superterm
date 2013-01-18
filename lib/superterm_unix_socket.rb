class Superterm::Unix_socket
  def initialize(args)
    @args = args
    
    #Remove the sock-file if it already exists.
    File.unlink(Superterm::CONFIG[:sock_path]) if File.exists?(Superterm::CONFIG[:sock_path])
    
    #Start Unix-socket.
    require "socket"
    @usock = UNIXServer.new(Superterm::CONFIG[:sock_path])
    
    #Remove the sock-file after this process is done.
    Kernel.at_exit do
      File.unlink(Superterm::CONFIG[:sock_path]) if File.exists?(Superterm::CONFIG[:sock_path])
    end
    
    #Start thread that listens for connections through the Unix-socket.
    Thread.new do
      begin
        while client = @usock.accept
          client.each_line do |line|
            line = line.strip
            
            if line.strip == "open_win_main"
              @args[:win_main].show_hide_trigger
            else
              print "Unknown line: #{line}\n"
            end
          end
        end
      rescue => e
        $stderr.puts e.inspect
        $stderr.puts e.backtrace
      end
    end
  end
end