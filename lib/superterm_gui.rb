class Superterm::Gui
  def self.const_missing(name)
    require "#{File.dirname(__FILE__)}/../gui/#{name.to_s.downcase}.rb"
    raise "Still not defined: '#{name}'." if !Superterm::Gui.const_defined?(name)
    return Superterm::Gui.const_get(name)
  end
end