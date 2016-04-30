require 'atspi/requires'
require 'dbus'

# ATSPI is the entry point to access accessible objects.
module ATSPI
  class << self
    extend Forwardable

    # Checks if AT-SPI is activated on the system
    #
    # @return [true,false]
    def available?
      session_bus = DBus::SessionBus.instance
      session_bus.service('org.a11y.Bus').exists?
    end

    # Returns all desktops known to AT-SPI.
    #
    # @return [Array<Desktop>]
    #
    # @example
    #   ATSPI.desktops # => [#<ATSPI::Desktop:0xd4e81014 @index=0 @name="main">]
    #
    # @see https://developer.gnome.org/libatspi/stable/libatspi-atspi-registry.html#atspi-get-desktop atspi_get_desktop
    # @see https://developer.gnome.org/libatspi/stable/libatspi-atspi-registry.html#atspi-get-desktop-count atspi_get_desktop_count
    def desktops
      @desktops ||= if available?
        Libatspi.get_desktop_count.times.map do |idx|
          Desktop.new(Libatspi.get_desktop(idx))
        end
      else
        []
      end
    end

    # Returns all applications for the given desktop.
    #
    # @param desktop [Desktop]
    #
    # @return [Array<Application>]
    #
    # @example
    #   ATSPI.applications # => [#<ATSPI::Application:0x71d18014 @desktop=0 @name="gnome-terminal-server">, …]
    def applications(desktop = desktops.first)
      if desktop
        desktop.applications
      else
        []
      end
    end

    #@!method generate_keyboard_event(keyval, keystring, synth_type)
    #   Generates a custom keyboard event.
    #
    #   Delegates directly to libatspi's generate_keyboard_event[https://developer.gnome.org/libatspi/stable/libatspi-atspi-registry.html#atspi-generate-keyboard-event]
    #
    #   @param keyval [Integer]
    #   @param keystring [String]
    #   @param synth_type [Symbol] one of :sym, :string, :press, :release or :pressrelease
    #
    #   @return [true, false]
    #
    #@!method generate_mouse_event(x, y, name)
    #   Generates a custom mouse event.
    #
    #   Delegates directly to libatspi's generate_mouse_event[https://developer.gnome.org/libatspi/stable/libatspi-atspi-registry.html#atspi-generate-mouse-event]
    #
    #   @param x [Integer]
    #   @param y [Integer]
    #   @param name [String]
    #
    #   @return [true, false]
    delegate %i(generate_keyboard_event generate_mouse_event) => :Libatspi
  end
end