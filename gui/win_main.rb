class Superterm::Gui::Win_main
  attr_reader :terms, :gui
  
  def initialize(args = {})
    @args = args
    @terms = {}
    @term_next_id = 0
    self.show
  end
  
  def show
    if !@gui or @gui.destroyed? or @gui["window"].destroyed?
      puts "Spawning Builder."
      @gui = Gtk3assist::Builder.new.add_from_file("#{File.dirname(__FILE__)}/../glade/win_main.glade")
      
      puts "Connecting signals."
      @gui.connect_signals{|h| method(h)}
      
      puts "Adding terminal."
      self.add_terminal
      
      puts "Showing window."
      @gui["window"].keep_above = true
      @gui["window"].show_all
    else
      @gui["window"].show_all
    end
    
    
    #Make window 80% width of the monitor and 65% height. Then place it in the middle at the top.
    screen = @gui["window"].screen
    monitor_no = screen.primary_monitor
    monitor_geometry = screen.monitor_geometry(monitor_no)
    
    width, height = monitor_geometry.width, monitor_geometry.height
    
    window_width = (width.to_f * 0.8).to_i
    window_height = (height.to_f * 0.65).to_i
    
    @gui["window"].resize(window_width, window_height)
    
    pos_left = ((width.to_f - window_width.to_f) / 2).to_i
    pos_top = 0
    @gui["window"].move(pos_left, pos_top)
  end
  
  def on_window_focus_out_event
    @gui["window"].hide
  end
  
  def on_window_delete_event
    @gui["window"].hide
    return true
  end
  
  #Handels the event when the 'Add'-button is clicked.
  def on_btnAdd_clicked
    puts "Add clicked."
    self.add_terminal
  end
  
  #Adds a new terminal to the notebook.
  def add_terminal
    puts "Add new terminal."
    
    @term_next_id += 1
    id = @term_next_id
    
    term = Superterm::Gui::Win_main::Terminal.new(:id => id, :win_main => self)
    @terms[id] = term
    
    @gui["nbTerminals"].append_page(term.term, term.label)
    @gui["nbTerminals"].show_all
    
    term.change_to_page
    
    term.term.grab_focus
  end
  
  class Terminal
    attr_reader :label, :term
    
    def initialize(args)
      @args = args
      @label = Gtk::Label.new(sprintf(_("Terminal %s"), @args[:id]))
      
      @term = Vte::Terminal.new
      @term.signal_connect("child-exited", &self.method(:on_child_exit))
      @term.signal_connect("window-title-changed", &self.method(:on_windowTitle_changed))
      
      @bash_pid = @term.fork_command_full(Vte::PtyFlags[:default], ENV["HOME"], ["/bin/bash"], [], GLib::SpawnFlags[:do_not_reap_child], nil, nil)
    end
    
    def on_child_exit(*args)
      self.remove_term
      
      if @args[:win_main].terms.empty?
        @args[:win_main].gui["window"].destroy
      end
    end
    
    def on_windowTitle_changed(*args)
      @label.label = @term.window_title
    end
    
    def page_num
      page_num = @args[:win_main].gui["nbTerminals"].page_num(@term)
    end
    
    def remove_term
      @args[:win_main].gui["nbTerminals"].remove_page(self.page_num)
      @args[:win_main].terms.delete(@args[:id])
    end
    
    def change_to_page
      @args[:win_main].gui["nbTerminals"].page = self.page_num
    end
  end
end