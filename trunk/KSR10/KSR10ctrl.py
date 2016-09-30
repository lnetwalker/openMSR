#!/usr/bin/python

# KSR10ctrl
# a python program to control the Vellemann KSR10 roboter arm
# depending on commands from the OpenMSR DeviceServer
# the commands are values in 2 iogroups. Every bit an axis is assigned
# whenever a bit is set to high the appropriate motor is switched on
# (c) 2016 by Hartmut Eilers <hartmut@eilers.net>
# released und the terms of the GNU GPL V2.0 or later


# input assignment
# first iogroups
# bit    axis
# 0      base left
# 1      base right
# 2      shoulder down
# 3      shoulder up
# 4      elbow down
# 5      elbow up
# 6      wrist down
# 7      wrist up

# second iogroups
# 0      grip close
# 1      grip Open
# 2      lights

# import http library
import requests
# import roboter lib
import ksr10
# import useful stuff
from time import sleep
import sys
import readchar


def strip_html( raw ):
  # strip off html stuff
  bare=Response.text.replace("<html><body>","")
  bare=bare.replace("</body></html>","")
  bare=bare.replace(" ","")
  return bare

# get the commandline parameters
for index, value in enumerate(sys.argv):
    print index, value
    if value[:3] == "url":
      URL = value[4:]
      if URL[len(URL)-1] <> "?" :
         URL = URL + "?"
    if value[:2] == "io":
      iogroup = value[3]


# make an instance off the ksr10
ksr=ksr10.ksr10_class()

#switch on the lights and move a bit
ksr.lights()
ksr.move("elbow","up")
ksr.stop()

# run the loop 
while (True):
  command = ""
  #Response = requests.get('http://prog.hucky.net:10080/index.html', headers={ "User-Agent": "Mozilla Banana" }, data = {'1':'1'})
  #Response = requests.get('http://homecontrol.hucky.net:10080/analog/read.html?1', headers={ "user-agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/49.0.2623.108 Chrome/49.0.2623.108 Safari/537.33" })
  Response = requests.get(URL + iogroup)
  print ( URL + iogroup)
  if Response <> "<Response [200]>":
    command = strip_html(Response.text)
    second_iogroup = str(int(iogroup) +1)
    Response = requests.get( URL + second_iogroup )
    if Response <> "<Response [200]>":
      command = command + strip_html(Response.text)
    # /if second request
    print (command)    
    # now we have an 11 bit string we need to process
    # switch on the motors
    if command[0] == "1":
      ksr.move("base","down")
    if command[1] == "1":
      ksr.move("base","up")
    if command[2] == "1":
      ksr.move("shoulder","down")
    if command[3] == "1":
      ksr.move("shoulder","up")
    if command[4] == "1":
      ksr.move("elbow","down")
    if command[5] == "1":
      ksr.move("elbow","up")
    if command[6] == "1":
      ksr.move("wrist","down")
    if command[7] == "1":
      ksr.move("wrist","up")
    if command[8] == "1":
      ksr.move("grip","close")
    if command[9] == "1":
      ksr.move("grip","open")
    if command[10] == "1":
      ksr.lights()
      
    # wait 50 ms
    sleep(0.05)
    
    # switch off all motors
    ksr.stop()

  # /if first request

# /while
