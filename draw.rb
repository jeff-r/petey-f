#!/usr/bin/env ruby

require 'gtk2'

# Draw a point where the user pressed the mouse and points on each
# of the four sides of that point.

# Gdk::EventButton
def button_pressed(area, event, arr)
  x = event.x
  y = event.y
  points = [ [x,y], [x+1,y], [x-1,y], [x,y+1], [x,y-1] ]
  area.window.draw_points(area.style.fg_gc(area.state), points)
  arr << [x, y]
end

# Draw a point where mouse pointer was moved while a button was
# pressed along with points on each of the four sides of that point.

# Gdk::EventMotion
def motion_notify(area, event, arr)
  x = event.x
  y = event.y
  points = [ [x,y], [x+1,y], [x-1,y], [x,y+1], [x,y-1] ]
  area.window.draw_points(area.style.fg_gc(area.state), points)
  arr << [x, y]
end

# Clear the drawing area when the user presses the Delete key,
# and demonstrate Gdk::Drawable drawing methods if the "+" key
# is pressed.

# Gdk::EventKey
def key_pressed(area, event, arr)
  if event.keyval == Gdk::Keyval::GDK_Delete
    area.window.clear
    arr.each { |e| e[0] = e[1] = 0 }
  elsif event.keyval == Gdk::Keyval::GDK_plus
    alloc = area.allocation
    area.window.draw_rectangle(area.style.fg_gc(area.state), false, 10, 10, 100, 50)
    area.window.draw_arc(area.style.fg_gc(area.state), true,
             alloc.width/2, alloc.height/2, alloc.width/2, alloc.height/2, 0, 64 * 360)
  end
end

# Redraw all of the points when an expose-event occurs. If you do
# not do this, the drawing area will be cleared.

# Gdk::EventExpose
def expose_event(area, event, arr)
  # Loop through the coordinates, redrawing them onto
  # the drawing area.
  arr.each do |e|
    points = []
    x = e[0]
    y = e[1]
    points = [ [x,y], [x+1,y], [x-1,y], [x,y+1], [x,y-1] ]
    area.window.draw_points(area.style.fg_gc(area.state), points)
  end
end
window = Gtk::Window.new(Gtk::Window::TOPLEVEL)
window.resizable = true
window.title = "Drawing Areas"
window.border_width = 10

window.signal_connect('delete_event') { Gtk.main_quit }
window.set_size_request(200, 150)

# Create a pointer array to hold image data. Then, add event
# masks to the new drawing area widget.

parray = Array.new
area = Gtk::DrawingArea.new
area.can_focus = true

# Gtk::Widget#add_events
area.add_events(Gdk::Event::BUTTON_PRESS_MASK  |
                Gdk::Event::BUTTON_MOTION_MASK |
                Gdk::Event::KEY_PRESS_MASK)

area.signal_connect('button_press_event')  { |w, e| button_pressed(area, e, parray) }
area.signal_connect('motion_notify_event') { |w, e| motion_notify( area, e, parray) }
area.signal_connect('key_press_event')     { |w, e| key_pressed(   area, e, parray) }
area.signal_connect('expose_event')        { |w, e| expose_event(  area, e, parray) }

window.add(area)
window.show_all

# You must do this after the widget is visible because
# it must first be realized for the GdkWindow to be valid!

# Gdk::Window#set_cursor
# gdk_window_set_cursor (area->window, gdk_cursor_new (GDK_PENCIL))

area.window.set_cursor(Gdk::Cursor.new(Gdk::Cursor::PENCIL))

Gtk.main
