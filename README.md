# Petey F

A bare-bones pdf viewer.

The main problem it solves is that I want to read pdf books on a laptop. 

Basically, I don't want the precious screen real estate to be taken up by toolbars, title bars, or page margins.

Lots of readers will let me view pdfs full screen. But I want to then zoom in until the top and bottom page margins are off the screen, and maybe scroll up or down to center the page. And when I move to the next page, I don't want to have to do that again.

And that's all Petey F does. 

I threw this together in Ruby, using GTK to make the window, and Poppler to display the pdfs.

And I don't have much experience doing GTK with Ruby, so I haven't taken the time to provide much of a user interface. I got this to the point where it was useful to me, and does what I need it to do, and then I've stopped.

I will probably flesh it out some in a bit; but until then, if you want it to do more, feel free to add features and push them back to me.

Or, if you like Petey, but don't have the skills to add to it, tell me. You might be able to guilt me into adding your features ...

## Installation

You'll probably need to install a few libraries to get this to work.

On Ubuntu, it's easy:

    sudo apt-get install ruby-gnome2-dev libpoppler-glib-ruby


## Other systems

It should run easily enough on any Linux, and probably OS X. But I haven't had the time to work out how, yet.  If you get it running on another system, let me know how you did it, and I'll add that here.

## Usage

On the command line, tell petey what pdf to view, and what page to begin at:

    ./peteyf.rb book.pdf 30

This will open book.pdf at page 30.

Once in, use keys to move around:

    quit:        q
    zoom in:     z or . or =
    zoom out:    x or , or -
    full screen: f or F11
    next page:   right arrow or mouse click 
    prev page:   left arrow
    
  

