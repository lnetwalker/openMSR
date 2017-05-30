#!/usr/bin/python

import ksr10
import time

# create object
ksr = ksr10.ksr10_class()

# turn on lights
ksr.lights()

# move base of the arm to the left
ksr.move("base","left")

# wait 0.5 second
time.sleep(.5)

# stop all movement
ksr.stop()

# move base to the right and 
# elbow up simultaneously
ksr.move("base","right")
ksr.move("elbow","up")

# wait 0.5 second
time.sleep(.5)

# stop all movement
ksr.stop()

# turn off lights
ksr.lights()
