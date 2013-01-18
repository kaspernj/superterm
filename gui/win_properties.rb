class Superterm::Gui::Win_properties
  def initialize(args)
    @args = args
    
    @win_main = @args[:win_main]
    
    @gui = Gtk3assist::Builder.new.add_from_file("#{File.dirname(__FILE__)}/../glade/win_properties.glade")
    @gui.connect_signals{|h| method(h)}
    
    @gui["txtScrollbackLines"].text = Knj::Opts.get("scrollback_lines")
    
    @gui["window"].show_all
  end
  
  def on_btnSave_clicked
    begin
      new_lines = @gui["txtScrollbackLines"].text.to_i
      raise sprintf(_("Invalid value: '%s'."), new_lines) if new_lines < 100
    rescue => e
      Gtk3assist::Msgbox.error(e)
      return
    end
    
    Knj::Opts.set("scrollback_lines", @gui["txtScrollbackLines"].text)
    @win_main.events.call(:on_scrollback_lines_changed, :new_value => new_lines)
    @gui["window"].destroy
  end
end