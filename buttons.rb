#!/usr/bin/env ruby

require 'gtk2'
require 'poppler'

class Viewer
  def initialize
    @current_scale = 1.1

    window = Gtk::Window.new
    window.border_width = 10
    window.set_size_request(650, -1)
    window.title = "Vd. - Boxes"

    window.signal_connect('delete_event') { false }
    window.signal_connect('destroy') { Gtk.main_quit }

    labels = %w[Andrew Joe Samantha Jonatan]

    # homogeneous, spacing
    hbox = Gtk::HBox.new(false, 0)

    labels.each do |name|
      btt = Gtk::Button.new(name)
      btt.signal_connect("clicked") {btt.destroy}
      hbox.pack_start_defaults(btt) 
    end


    @window = window
    @main_hbox = hbox

    filename = 'gnome-foot.png'
    pixbuf = Gdk::Pixbuf.new(filename)
    pack_pixbuf pixbuf
  end


  def pixbuf_from_pdf filename
    @current_doc  = Poppler::Document.new filename
    @current_page = @current_doc.get_page(0)
    page_w, page_h = @current_page.size

    page_w *= @current_scale
    page_h *= @current_scale

	  pixbuf = Gdk::Pixbuf.new(Gdk::Pixbuf::COLORSPACE_RGB, false, 8, page_w, page_h)

    rotation = 0
    @current_page.render(0,0, page_w, page_h, @current_scale, rotation, pixbuf)
    pixbuf
  end


  def render_current_page
  end

  def pack_pixbuf pixbuf
    image = Gtk::Image.new(pixbuf)
    @main_hbox.pack_start(image, true, true, 0) 
  end

  def show
    @window.add(@main_hbox)
    @window.show_all
    Gtk.main
  end

  def show_pdf filename
    pack_pixbuf pixbuf_from_pdf filename, 1.5
    # doc = Poppler::Document.new filename
    # puts "number of pages: #{doc.n_pages}"
  end
end

v = Viewer.new
v.show_pdf 'test.pdf'
v.show
