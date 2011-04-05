#!/usr/bin/env ruby

require 'gtk2'
require 'poppler'

class Viewer
  def initialize
    @not_loaded = true
    @current_scale = 1.1

    window = Gtk::Window.new
    window.border_width = 0
    window.set_size_request(650, -1)
    window.title = "Vd. - Boxes"

    window.signal_connect('delete_event') { false }
    window.signal_connect('destroy') { Gtk.main_quit }
    # window.signal_connect('expose_event') { puts "expose event" }
    window.signal_connect('size_allocate') { 
      # puts "@window: #{@window.allocation.width.inspect}"
      # render_current_page
    }

    window.signal_connect('key_release_event') { |widget, event| 
      handle_key event.keyval
    }


    labels = %w[Andrew Joe Samantha Jonatan]

    # homogeneous, spacing
    hbox = Gtk::HBox.new(false, 0)

    # labels.each do |name|
    #   btt = Gtk::Button.new(name)
    #   btt.signal_connect("clicked") {btt.destroy}
    #   hbox.pack_start_defaults(btt) 
    # end


    @window = window
    @main_hbox = hbox

  end

  def handle_key keyval
    puts "Key event: #{keyval.inspect}"
    case keyval 
      when 107 then taller
      when 108 then wider

      when Gdk::Keyval.from_name("GDK_KEY_K") then wider
      when Gdk::Keyval.from_name("GDK_KEY_J") then taller
      # when GdkKeyvals.GDK_K then wider
      # when GdkKeyvals.GDK_J then taller
    end
  end

  def wider
    w,h = @window.size
    @window.resize w+10, h
    render_current_page
  end
  def taller
    w,h = @window.size
    @window.resize w, h+10
    render_current_page
  end

  def pixbuf_from_pdf filename
    @current_doc  = Poppler::Document.new filename
    @current_page_num = 0
    @current_page = @current_doc.get_page(@current_page_num)
    page_w, page_h = @current_page.size

    page_w *= @current_scale
    page_h *= @current_scale

	  pixbuf = Gdk::Pixbuf.new(Gdk::Pixbuf::COLORSPACE_RGB, false, 8, page_w, page_h)

    rotation = 0
    @current_page.render(0,0, page_w, page_h, @current_scale, rotation, pixbuf)
    pixbuf
  end

  # Get the scale, based on the current page size and the available area
  def get_doc_scale w, h
    page_w, page_h = @current_page.size

    scale_x = w / page_w 
    scale_y = h / page_h

    if scale_x > scale_y
      scale_y
    else
      scale_x
    end
  end

  def render_current_page
    if @not_loaded
      return
    end
    w = @window.allocation.width
    h = @window.allocation.height
    @current_scale = get_doc_scale w, h
  
    rotation = 0

	  pixbuf = Gdk::Pixbuf.new(Gdk::Pixbuf::COLORSPACE_RGB, false, 8, w, h)
    @current_page.render(0,0, w, h, @current_scale, rotation, pixbuf)

    @current_page_image.set_pixbuf pixbuf
  end

  def pack_pixbuf pixbuf
    @current_page_image = Gtk::Image.new(pixbuf)
    @main_hbox.pack_start(@current_page_image, true, true, 0) 
  end

  def show
    @window.add(@main_hbox)
    @window.show_all
    @not_loaded = false
    Gtk.main

  end

  def show_pdf filename
    pack_pixbuf pixbuf_from_pdf filename
  end
end

v = Viewer.new
v.show_pdf 'test.pdf'
v.show
