# Petey F

A bare-bones pdf viewer.

At the moment, Petey F is probably not very usable for other people, although it might get there.

The main problem it solves -- for me -- is that I want to read pdfs on a laptop, I want to zoom in as much as the small screen allows. 

So I want the pdf viewer to go full screen, and to have no title bars or toolbars or menu bars taking up screen space. 

And I want to be able to scroll down past the page's top margin, and zoom in or out until the bottom margin is off the page, too.

And I'm reading books, which means that each page has the same top and bottom margins ... so I don't want to have to zoom or scroll again when I go to the next page.

And that's what Petey F does. 

I threw this together in Ruby, using GTK to make the window, and Poppler to display the pdfs.

And I don't have much experience doing GTK with Ruby, so I haven't taken the time to provide muchof a user interface. I got this to the point where it was useful to me, and does what I need it to do, and then I've stopped.

I will probably flesh it out some in a bit; but until then, if you want it to do more, feel free to add features and push them back to me.

Or, if you like Petey, but don't have the skills to add to it, tell me. You might be able to guilt me into adding your features ...

## Instalation

You'll probably need to install a few libraries to get this to work.

On Ubuntu, it's easy:

    sudo apt-get install ruby-gnome2-dev libpoppler-glib-ruby


## Other systems

It should run easily enough on any Linux, and probably OS X. But I haven't had the time to work out how, yet.  If you get it running on another system, let me know how you did it, and I'll add that here.

