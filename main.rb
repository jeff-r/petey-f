#!/usr/bin/env ruby

require './common'

module PeteyF
  class MainWindow < BasicWindow
    def initialize
      super 'Petey F'

      @pixbuf_loader = nil
      @load_timeout = 0
      @image_stream = nil

      super('Images')
      signal_connect('destroy') do
        cleanup_callback
      end

      self.border_width = 8

      vbox = Gtk::VBox.new(false, 8)
      vbox.border_width = 8

      label = Gtk::Label.new
      label.set_markup('<u>Image loaded from a file</u>')
      vbox.pack_start(label, false, false, 0)

      # frame = Gtk::Frame.new
      # frame.shadow_type = Gtk::SHADOW_IN

      # # The alignment keeps the frame from growing when users resize
      # # the window
      # align = Gtk::Alignment.new(0.5, 0.5, 0, 0)
      # align.add(frame)
      # vbox.pack_start(align, false, false, 0)

      # demo_find_file looks in the the current directory first,
      # so you can run gtk-demo without installing GTK, then looks
      # in the location where the file is installed.
      pixbuf = nil
      # begin
      #   filename = Demo.find_file('gtk-logo-rgb.gif')
      #   pixbuf = Gdk::Pixbuf.new(filename)
      # rescue
      #   # This code shows off error handling. You can just use
      #   # Gtk::Image.new instead if you don't want to report
      #   # errors to the user. If the file doesn't load when using
      #   # Gtk::Image.new, a 'missing image' icon will
      #   # be displayed instead.
      #   dialog = Gtk::MessageDialog.new(self,
      #                                   Gtk::Dialog::DESTROY_WITH_PARENT,
      #                                   Gtk::MessageDialog::ERROR,
      #                                   Gtk::MessageDialog::BUTTONS_CLOSE,
      #                                   "Unable to open image file 'gtk-logo-rgb.gif': #{$1}")

      #   dialog.signal_connect('response') do |widget, data|
      #     widget.destroy
      #   end
      #   dialog.show
      # end

      # image = Gtk::Image.new(pixbuf)
      # frame.add(image)

      button = Gtk::Button.new 'Push'
      button.signal_connect( 'clicked' ) do
        puts "pushed!"
      end

      vbox.pack_start(button, true, false, 0)

      add(vbox)

    end
  end
end

win = PeteyF::MainWindow.new
win.show
Gtk.main

