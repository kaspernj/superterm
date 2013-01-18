require "rubygems"
require "gettext"
require "sqlite3"
require "fileutils"

begin
  require "#{File.dirname(__FILE__)}/../../knjrbfw/lib/knjrbfw.rb"
rescue LoadError
  require "knjrbfw"
end

puts "Making config-path in home-dir."
path = "#{Knj::Os.homedir}/.superterm"
Dir.mkdir(path) if !File.exists?(path)

class Superterm
  CONFIG = {
    :path => "#{Knj::Os.homedir}",
    :conf_path => "#{Knj::Os.homedir}/.superterm",
    :sock_path => "#{Knj::Os.homedir}/.superterm/sock",
    :run_path => "#{Knj::Os.homedir}/.superterm/run"
  }
  
  def self.const_missing(name)
    require "#{File.dirname(__FILE__)}/superterm_#{name.to_s.downcase}.rb"
    raise "Still not defined: '#{name}'." if !Superterm.const_defined?(name)
    return Superterm.const_get(name)
  end
  
  def self.start
    do_start = false
    FileUtils.touch(CONFIG[:run_path]) if !File.exists?(CONFIG[:run_path])
    
    File.open(CONFIG[:run_path]) do |fp|
      fp.flock(File::LOCK_EX)
      pid = File.read(CONFIG[:run_path]).to_i
      
      if pid <= 0 or !Knj::Unix_proc.pid_running?(pid)
        do_start = true
        File.open(CONFIG[:run_path], "w") do |fp_w|
          fp_w.write Process.pid
        end
        
        Kernel.at_exit do
          File.unlink(CONFIG[:run_path])
        end
      end
    end
    
    if do_start
      puts "Loading Gtk3 and Vte."
      require "gir_ffi-gtk3"
      Knj.gem_require(:Gtk3assist)
      GirFFI.setup :Vte
      Gtk.init
      
      puts "Enable threadding."
      Gtk3assist::Threadding.enable_threadding
      
      puts "Opening database."
      db = Knj::Db.new(
        :type => "sqlite3",
        :path => "#{CONFIG[:conf_path]}/superterm.sqlite3",
        :index_append_table_name => true,
        :return_keys => "symbols"
      )
      Knj::Db::Revision.new.init_db("db" => db, "schema" => Superterm::Dbschema::SCHEMA)
      
      puts "Loading options."
      Knj::Opts.init("knjdb" => db, "table" => "Option")
      
      win_main = Superterm::Gui::Win_main.new(:db => db)
      Superterm::Unix_socket.new(:win_main => win_main)
      
      Gtk.main
    else
      cmd = nil
      ARGV.each do |val|
        if match = val.match(/^--cmd=(.+)$/)
          cmd = match[1]
          break
        elsif match = val.match(/^--help$/)
          puts "Possible commands:"
          puts "  --help                    - Shows this message."
          puts "  --cmd=open_show_main      - Shows the terminal and forces focus. Useful for shortcut bindings."
        else
          $stderr.puts "Unknown argument: '#{val}'."
          exit
        end
      end
      
      if cmd
        puts "Executing command through sock: #{cmd}"
        
        require "socket"
        UNIXSocket.open(CONFIG[:sock_path]) do |sock|
          sock.puts(cmd)
        end
      end
    end
  end
end

#Fake support for Gettext. Makes it easier to implement later.
def _(str)
  return str.to_s
end