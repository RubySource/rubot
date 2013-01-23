RuBot = Ruby + Arduino + LEGO®
##############################

RuBot is a simple web-controlled robot that I built just for fun on a rainy weekend.

It utilizes a modified [Uvccapture](http://staticwave.ca/source/uvccapture) version
to provide a motion JPEG stream to the operators browser.

Visit [RubySource.com](http://rubysource.com/author/mberszick/) to find the article
I wrote about this cool little project.



QuickStart Guide
----------------

* Read the article and build a robot like mine

* Copy this code to the robot

* Flash the code in rubot.pde to the robots Arduino

* Compile the modified Uvccapture source using `make` and copy the binary into the
main folder

* Connect the robots Arduino to the robots computer via USB and set generous permissions
to the new serial device (e.g. /dev/ttyUSB0)

* Run rubot.rb and visit http://<your-robots-ip>:4567 with another computers browser

* Enjoy the ride :) 