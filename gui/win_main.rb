class Superterm::Gui::Win_main
  attr_reader :events, :terms, :gui
  
  def initialize(args = {})
    @args = args
    @db = @args[:db]
    raise "No database given." if !@db
    @terms = {}
    @term_next_id = -1 #First will be 0.
    @hidden = true
    
    #Set the scrollback-lines from the saved value in the database.
    scrollback_lines_val = Knj::Opts.get("scrollback_lines").to_i
    scrollback_lines_val = 1000 if scrollback_lines_val < 1000
    self.scrollback_lines = scrollback_lines_val
    
    #Used for various callbacks.
    @events = Knj::Event_handler.new
    
    #Event when scrollback lines are changed. Called from the properties window.
    @events.add_events(:on_scrollback_lines_changed)
    @events.connect(:on_scrollback_lines_changed, &self.method(:on_scrollback_lines_changed))
    
    self.show
  end
  
  def scrollback_lines=(new_val)
    @terms.each do |key, term|
      term.scrollback_lines = new_val
    end
  end
  
  #Called when the number of scrollback lines are changed through the properties.
  def on_scrollback_lines_changed(event, args)
    new_val = args[:new_value]
    
    #Set the new value on the terminals.
    self.scrollback_lines = new_val
  end
  
  def on_window_hide
    puts "Main window was hidden."
    @hidden = true
  end
  
  def on_window_show
    puts "Main window was shown."
    @hidden = false
  end
  
  def show_hide_trigger
    if !@hidden
      puts "Window wasnt hidden - hide it."
      @gui["window"].hide
    else
      puts "Window was hidden - show it."
      self.show
    end
  end
  
  def show
    if @gui and @gui["window"]
      #puts @gui["window"].methods.sort if @gui and @gui["window"]
      
      state = @gui["window"].get_state
      puts "State: #{state}"
    end
    
    if !@gui or !@gui["window"]
      puts "Spawning Builder."
      @gui = Gtk3assist::Builder.new.add_from_file("#{File.dirname(__FILE__)}/../glade/win_main.glade")
      
      puts "Connecting signals."
      @gui.connect_signals{|h| method(h)}
      
      puts "Adding terminal."
      self.add_terminal
      
      puts "Showing window."
      @gui["window"].keep_above = true
      @gui["window"].show_all
    elsif @hidden
      puts "Opening window and setting focus."
      @gui["window"].show_all
      
      puts "Setting focus to terminal in case it wasnt."
      term = self.active_terminal
      term.term.grab_focus
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
    puts "Focus out event - hide."
    @gui["window"].hide
  end
  
  def on_window_destroy
    puts "Main window closed - killing main loop to end application."
    Gtk.main_quit
  end
  
  #Handels the event when the 'Add'-button is clicked.
  def on_btnAdd_clicked
    puts "Add clicked."
    self.add_terminal
  end
  
  def on_btnProperties_clicked
    Superterm::Gui::Win_properties.new(:win_main => self)
  end
  
  #Returns the current active terminal according to the notebook page.
  def active_terminal
    cur_page = @gui["nbTerminals"].get_current_page
    term = @terms[cur_page]
    return term
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
    
    def scrollback_lines=(newnum)
      @term.set_scrollback_lines(newnum)
    end
    
    def on_child_exit(*args)
      self.remove_term
      
      if @args[:win_main].terms.empty?
        @args[:win_main].gui["window"].hide
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