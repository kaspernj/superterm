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
      @gui = Gtk::Builder.new.add("#{File.dirname(__FILE__)}/../glade/win_main.glade")
      @gui.connect_signals{|h| method(h)}
      
      self.add_terminal
      @gui["window"].show_all
    else
      @gui["window"].show_all
    end
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
      
      @bash_pid = @term.fork_command("bash")
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