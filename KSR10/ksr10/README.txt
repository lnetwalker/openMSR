KSR10 USB Python controller

  What is it?
  -----------

  The KSR10 USB Python controller is a tool to control a popular
  robotarm called 'KSR10', manufactured by Velleman. The KSR10 by
  Velleman comes with an optional USB interface, but with limited
  software control.
  This project aims to add a Python control environment in wich
  the robot arm can be controlled using various input devices, such
  as mouse, joystick, and even voice control.

  
  Documentation
  -------------

  There is a (very) small amount of documentation available at:
  https://sourceforge.net/p/ksr10usbpython/wiki/Home/
  

  Installation and use
  --------------------

  Simply download the package and place the scripts in the directory 
  of your choice. Open up your favorite Python shell and import the 
  ksr10.py file with
    import ksr10
  then create a new object, like
    ksr = ksr10.ksr10.ksr10_class()
  Then the following methods apply:
    ksr.stop()                  ; will stop all movement
    ksr.lights()                ; will turn on or turn off the lights
    ksr.move(part,direction)    ; will move "part" in certain 
                                  "direction", like 
                                  ksr.move("shoulder","down") will 
                                  move the shoulder down. 
  Please note that the ksr10 will not stop moving unless you 
  command it do so with ksr.stop().
  
  
  Licensing
  ---------

  Creative Commons Attribution ShareAlike License V2.0
  
