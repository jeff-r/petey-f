#!/usr/bin/env ruby

# See https://github.com/Jeff-R/petey-f

require 'gtk2'
require 'poppler'

class Viewer
  def initialize
    @not_loaded = true
    @current_scale = 1.1
    @x = 0
    @y = 0
    @zoom = 1
    @zoom_delta = 0.025

    window = Gtk::Window.new
    window.border_width = 0

    window.set_size_request(650, -1)
    window.title = "Petey F"

    window.signal_connect('delete_event') { false }
    window.signal_connect('destroy') { quit }
    # window.signal_connect('expose_event') { puts "expose event" }
    window.signal_connect('size_allocate') { 
    }

    window.signal_connect('key_release_event') do |widget, event| 
      handle_key event.state, event.keyval
    end

    window.signal_connect('window_state_event') do |widget, event| 
      @window_state = event.new_window_state
    end

    # homogeneous, spacing
    hbox = Gtk::HBox.new(false, 0)

    @window = window
    @main_hbox = hbox
  end

  def maximized?
    @window_state == Gdk::EventWindowState::MAXIMIZED
  end

  def full_screen?
    @window_state == Gdk::EventWindowState::FULLSCREEN
  end

  def handle_key state, keyval
    case keyval 
      when Gdk::Keyval::GDK_d then @window.decorated = (not @window.decorated)
      when Gdk::Keyval::GDK_j      then shift_down       
      when Gdk::Keyval::GDK_k      then shift_up       
      when Gdk::Keyval::GDK_l      then wider       
      when Gdk::Keyval::GDK_m      then goto_page   
      when Gdk::Keyval::GDK_q      then quit 
      when Gdk::Keyval::GDK_r      then render_current_page   
      when Gdk::Keyval::GDK_f      then toggle_fullscreen
      when Gdk::Keyval::GDK_F11    then toggle_fullscreen
      when Gdk::Keyval::GDK_Right  then next_page   
      when Gdk::Keyval::GDK_Left   then prev_page   

      when Gdk::Keyval::GDK_z      then zoom_in
      when Gdk::Keyval::GDK_x      then zoom_out
      when Gdk::Keyval::GDK_comma  then zoom_out
      when Gdk::Keyval::GDK_period then zoom_in
      when Gdk::Keyval::GDK_minus  then zoom_out
      when Gdk::Keyval::GDK_equal  then zoom_in

      when (state.control_mask?    and Gdk::Keyval::GDK_Up)    then taller
      when (state.control_mask?    and Gdk::Keyval::GDK_Right) then wider 
      when (state.control_mask?    and Gdk::Keyval::GDK_Down)  then shorter
      when (state.control_mask?    and Gdk::Keyval::GDK_Left)  then thinner 
      # when Gdk::Keyval::GDK_f then full_height 
      # when Gdk::Keyval::GDK_Space then next_page   
    end
  end

  def toggle_fullscreen
    if full_screen?
      @window.unfullscreen
    else
      @window.fullscreen
    end
    render_current_page true
  end

  def quit
    puts "leaving file #{@current_filename} at page #{@current_page_num}"
    Gtk.main_quit
  end

  def next_page
    @current_page_num += 1
    if @current_page_num == @current_doc.n_pages
      @current_page_num = @current_doc.n_pages-1
    end
    render_current_page
  end

  def zoom_in
    @zoom += @zoom_delta
    render_current_page
  end

  def zoom_out
    @zoom -= @zoom_delta
    render_current_page
  end

  def prev_page
    @current_page_num -= 1
    if @current_page_num < 0
      @current_page_num = 0
    end
    render_current_page
  end

  def full_height
    new_h = @window.screen.height
    w,h = @window.size

    aspect_ratio = w.to_f/h.to_f
    puts "aspect_ratio: #{aspect_ratio}"
    new_w = aspect_ratio * new_h
    puts "new_w: #{new_w}"
    @window.resize new_w, new_h
    render_current_page
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

  def thinner
    w,h = @window.size
    @window.resize w-10, h
    render_current_page
  end
  def shorter
    w,h = @window.size
    @window.resize w, h-10
    render_current_page
  end

  def shift_up
    @y -= 10
    render_current_page
  end

  def shift_down
    @y += 10
    render_current_page
  end

  def pixbuf_from_pdf filename, page_num
    @current_filename = filename
    @current_doc  = Poppler::Document.new filename
    if page_num < @current_doc.n_pages
      @current_page_num = page_num
    else
      @current_page_num = @current_doc.n_pages
    end
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

  def render_current_page fullscreen = false
    if @not_loaded
      return
    end
    @current_page = @current_doc.get_page(@current_page_num)
    if fullscreen 
      w = @window.screen.width
      h = @window.screen.height
    else
      w = @window.allocation.width
      h = @window.allocation.height
    end
    @current_scale = get_doc_scale w, h
  
    rotation = 0

    doc_w, doc_h = @current_page.size
    scale = @current_scale * @zoom
	  pixbuf = Gdk::Pixbuf.new(Gdk::Pixbuf::COLORSPACE_RGB, false, 8, w, h)
    pixbuf.fill! 0x00000000
    @current_page.render(@x, @y, scale*doc_w, scale*doc_h, scale, rotation, pixbuf)

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

  def show_pdf filename, page_num
    pack_pixbuf pixbuf_from_pdf(filename, page_num)

    # render_current_page
  end

  def goto_page
    puts "goto not implemented yet"
    return
    dialog = Gtk::Dialog.new('Interactive Dialog',
                               self,
                               Gtk::Dialog::MODAL | Gtk::Dialog::DESTROY_WITH_PARENT,
                               [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK],
                               ["_Non-stock Button", Gtk::Dialog::RESPONSE_CANCEL]
                              )

    puts "goto 2"
    hbox = Gtk::HBox.new(false, 0)
    hbox.set_border_width(8)
    dialog.vbox.pack_start(hbox, false, false, 0)

    stock = Gtk::Image.new(Gtk::Stock::DIALOG_QUESTION, Gtk::IconSize::DIALOG)
    hbox.pack_start(stock, false, false, 0)

    table = Gtk::Table.new(2, 2, false)
    table.set_row_spacings(4)
    table.set_column_spacings(4)
    hbox.pack_start(table, true, true, 0)
    label = Gtk::Label.new('_Entry 1', true)
    table.attach_defaults(label,
                          0, 1, 0, 1)
    local_entry1 = Gtk::Entry.new
    local_entry1.text = @entry1.text
    table.attach_defaults(local_entry1, 1, 2, 0, 1)
    label.set_mnemonic_widget(local_entry1)

    label = Gtk::Label.new('E_ntry 2', true)
    table.attach_defaults(label,
                          0, 1, 1, 2)

    local_entry2 = Gtk::Entry.new
    local_entry2.text = @entry2.text
    table.attach_defaults(local_entry2, 1, 2, 1, 2)
    label.set_mnemonic_widget(local_entry2)

    hbox.show_all
    response = dialog.run

    if response == Gtk::Dialog::RESPONSE_OK 
      @entry1.text = local_entry1.text
      @entry2.text = local_entry2.text
    end
    dialog.destroy

  end
end

v = Viewer.new
filename = ARGV[0]
pagenum  = ARGV[1].to_i

v.show_pdf filename, pagenum
v.show
