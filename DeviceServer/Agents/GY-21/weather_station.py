# -*- coding: iso-8859-15 -*-
# Copyright (c) 2016 IngeniApp
# Author: IngeniApp
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
import Image
import ImageDraw
import ImageFont
import time

import Adafruit_ILI9341 as TFT
import RPi.GPIO as RPGPIO
import Adafruit_GPIO.SPI as SPI
import gy21
import os
from smbus import SMBus
import ephem
from threading import Timer
from datetime import date
import calendar
import adc

YL40 = 0 # If you use YL-40 for brightness sensor set to 1. By default, your brightness sensor is connected to ADC directly

###### Global variables #######
# Your location
lat='40.340829'
long='-3.808226'
next_sunrise = ''
next_sunset = ''
lnext_sunrise = 0
lnext_sunset = 0
next_full_moon = ''
next_new_moon = ''
night_mode = 0
############################
# Raspberry Pi configuration.
DC = 24
RST = 25
SPI_PORT = 0
SPI_DEVICE = 0
LED = 18

# BeagleBone Black configuration.
# DC = 'P9_15'
# RST = 'P9_12'
# SPI_PORT = 1
# SPI_DEVICE = 0

# Create TFT LCD display class.
disp = TFT.ILI9341(DC, rst=RST, spi=SPI.SpiDev(SPI_PORT, SPI_DEVICE, max_speed_hz=64000000))

RPGPIO.setup(LED, RPGPIO.OUT)
'''
# Using python display lib cannot correct manage brightness
pwm = RPGPIO.PWM(LED, 1000)
pwm.start(100)
'''
# To correct control display brigthness
os.system("gpio -g mode 18 pwm; gpio pwmc 1000; gpio -g pwm 18 512 &") # Max brigth 1024
# Initialize display.
disp.begin()

# Draw a background image.
image = Image.open('./day.png')

# Resize the image and rotate it so it's 240x320 pixels.
image = image.rotate(270)
disp.buffer = image

# Alternatively load a TTF font.
# Some other nice fonts to try: http://www.dafont.com/bitmap.php

# Used fonts
font = ImageFont.truetype('./KeepCalm.ttf',26)
font_small = ImageFont.truetype('./metal.ttf', 20)
font_super_small = ImageFont.truetype('./KeepCalm.ttf', 12)
font_medium = ImageFont.truetype('./KeepCalm.ttf', 17)

# Init devices
try:
    T_H_sensor = 1
    print "Checking Temperature/Humidity sensor...",
    obj = gy21.HTU21D()
    print("   Sensor OK!")
except:
    T_H_sensor = 0
    print("   Sensor unplugged!")
    print "Checking 1-wire temperature sensor...",
    os.system("cat /sys/bus/w1/devices/28-*/w1_slave | grep -o 't=.....' | awk '{print $2}' FS='=' | tr -d '\n' > /tmp/tExt")
    try:
        f = open('/tmp/tExt', 'r')
        line = f.readline()
        f.close()
        temp_C = float(line) / 1000.0
        T_sensor = 1
        print("   Sensor OK!")
    except:
        T_sensor = 0
        print("   Sensor unplugged!")

msleep = lambda x: time.sleep(x/1000.0)
try:
    L_sensor = 1
    print "Checking Light sensor...",
    if YL40: # If YL40 variable set to 1
        bus = SMBus(1)
        bus.write_byte_data(0x48, 0x41, 1)
    else: # Your brightness sensor is connected to ADC directly
        adc_light = adc.MCP342X(0x68)
        adc_light.reset()
        msleep(1)
        adc_light.conversion()
        msleep(1)
        adc_light.configure(0) # CHANNEL_0 = 0
        if adc_light.read() > 65500:
            L_sensor = 0
            print("   Sensor unplugged!")
        else:
            print("   Sensor OK!")
except:
    L_sensor = 0
    print("   Sensor unplugged!")

def read_ain():
    global bus
    aout = 0
    for a in range(0, 4):
        aout = aout + 1
        bus.write_byte_data(0x48, 0x40 | ((a+1) & 0x03), aout)
        v = bus.read_byte(0x48)
        if a == 0:
            light = v
        time.sleep(0.1)
    return light

def show_time_temp():
    global night_mode
    temp_C = None
    if( T_H_sensor == 1 ):
        try:
            temp_C = obj.read_tmperature()
            humi = obj.read_humidity()
            print "Temp:", temp_C, "C"
            print "Humid:", humi, "% rH"
            cadhumi = "%.1f" % humi + "% rH "
        except:
            cadhumi = "----% rH "
            cadtemp = "----" + u"º" + "F / ----" + u"º" + "C"
            print("Error: temp/humid sensor!")
    elif( T_sensor == 1 ):
        try:
            cadhumi = "----% rH "
            f = open('/tmp/tExt', 'r')
            line = f.readline()
            f.close()
            temp_C = float(line) / 1000.0
            print "Temp:", temp_C, "C"
            # Background executed to not interfering main thread. Read 1-wire takes too long
            os.system("cat /sys/bus/w1/devices/28-*/w1_slave | grep -o 't=.....' | awk '{print $2}' FS='=' | tr -d '\n' > /tmp/tExt &")
        except:
            print("Error: 1-wire temperature sensor!")
    else:
        cadhumi = "----% rH "
        cadtemp = "----" + u"º" + "F / ----" + u"º" + "C"
    if temp_C!= 999 and temp_C != 85 and temp_C != None:
        temp_F = (temp_C * 9/5) + 32
        cadtemp = "%.1f" % temp_F + u"º" + "F / %.1f" % temp_C + u"º" + "C"
    else:
        cadtemp = "----" + u"º" + "F / ----" + u"º" + "C"

    ldate = float(time.strftime("%H%M%S"))
    if (ldate > lnext_sunrise and ldate < (lnext_sunrise + 3)):
        print "Ephem Update Sunrise"
        if night_mode == 1:
            night_mode = 0
            image = Image.open('./day.png')
            image = image.rotate(270)
            disp.buffer = image
        getEphem()
    if (ldate > lnext_sunset and ldate < (lnext_sunset + 3)):
        print "Ephem Update Sunset"
        if night_mode == 0:
            night_mode = 1
            image = Image.open('./night.png')
            image = image.rotate(270)
            disp.buffer = image
        getEphem()

    draw_rotated_text(disp.buffer, time.strftime("%d/%m/%y "), (220, 3), 270, font_small, fill=(255, 255, 255), bgtext=(0,0,0,255))
    draw_rotated_text(disp.buffer, time.strftime("%H:%M  "), (220, 270), 270, font_small, fill=(255, 255, 255), bgtext=(0,0,0,255))

    if night_mode == 0:
        draw_rotated_text(disp.buffer, calendar.day_name[date.today().weekday()][:7], (211, 120), 270, font_small, fill=(255, 255, 255), bgtext=(26,161,209,255))
        draw_rotated_text(disp.buffer, "Sunrise", (185, 108), 270, font_super_small, fill=(0, 153, 153), bgtext=(255,231,157,255))
        draw_rotated_text(disp.buffer, next_sunrise, (165, 88), 270, font_medium, fill=(107, 142, 35), bgtext=(254,224,129,255))
        draw_rotated_text(disp.buffer, "Sunset", (152, 108), 270, font_super_small, fill=(0, 153, 153), bgtext=(254,218,107,255))
        draw_rotated_text(disp.buffer, next_sunset, (132, 88), 270, font_medium, fill=(107, 142, 35), bgtext=(254,214,91,255))

        draw_rotated_text(disp.buffer, "New Moon", (185, 188), 270, font_super_small, fill=(255, 255, 255), bgtext=(23,157,205,255))
        draw_rotated_text(disp.buffer, next_new_moon, (165, 210), 270, font_medium, fill=(107, 122, 35), bgtext=(23,157,205,255))
        draw_rotated_text(disp.buffer, "Full Moon", (152, 217), 270, font_super_small, fill=(255, 255, 255), bgtext=(23,157,205,255))
        draw_rotated_text(disp.buffer, next_full_moon, (132, 227), 270, font_medium, fill=(107, 122, 35), bgtext=(23,157,205,255))

        draw_rotated_text(disp.buffer, "Weather now", (92, 40), 270, font_small, fill=(0, 153, 153), bgtext=(255,242,242,255))
        draw_rotated_text(disp.buffer, cadhumi, (40, 30), 270, font, fill=(107, 142, 35), bgtext=(255,242,242,255))
        draw_rotated_text(disp.buffer, cadtemp + " ", (5, 30), 270, font, fill=(107, 142, 35), bgtext=(255,242,242,255))
    else:
        draw_rotated_text(disp.buffer, calendar.day_name[date.today().weekday()][:7], (220, 100), 270, font_small, fill=(255, 255, 255), bgtext=(0,0,0,255))
        draw_rotated_text(disp.buffer, "Sunrise", (170, 125), 270, font_super_small, fill=(25, 216, 216), bgtext=(0,0,0,255))
        draw_rotated_text(disp.buffer, next_sunrise, (150, 105), 270, font_medium, fill=(149, 187, 72), bgtext=(0,0,0,255))
        draw_rotated_text(disp.buffer, "Sunset", (138, 125), 270, font_super_small, fill=(25, 216, 216), bgtext=(0,0,0,255))
        draw_rotated_text(disp.buffer, next_sunset, (120, 105), 270, font_medium, fill=(149, 187, 72), bgtext=(0,0,0,255))
        draw_rotated_text(disp.buffer, "New Moon", (170, 205), 270, font_super_small, fill=(0, 153, 153), bgtext=(255,220,33,255))
        draw_rotated_text(disp.buffer, next_new_moon, (150, 210), 270, font_medium, fill=(107, 142, 35), bgtext=(255,220,33,255))
        draw_rotated_text(disp.buffer, "Full Moon", (138, 205), 270, font_super_small, fill=(0, 153, 153), bgtext=(255,220,33,255))
        draw_rotated_text(disp.buffer, next_full_moon, (120, 210), 270, font_medium, fill=(107, 142, 35), bgtext=(255,220,33,255))
        draw_rotated_text(disp.buffer, "Weather now", (85, 25), 270, font_small, fill=(25, 216, 216), bgtext=(0,0,0,255))
        draw_rotated_text(disp.buffer, cadhumi, (40, 30), 270, font, fill=(9, 78, 19), bgtext=(255,220,33,255))
        draw_rotated_text(disp.buffer, cadtemp + " ", (5, 30), 270, font, fill=(9, 78, 19), bgtext=(255,220,33,255))
    disp.display()

# Define a function to create rotated text.  Unfortunately PIL doesn't have good
# native support for rotated fonts, but this function can be used to make a
# text image and rotate it so it's easy to paste in the buffer.
def draw_rotated_text(image, text, position, angle, font, fill=(255,255,255), bgtext=(255,255,255,255)):
    # Get rendered font width and height.
    draw = ImageDraw.Draw(image)
    width, height = draw.textsize(text, font=font)
    # Create a new image with transparent background to store the text.
    textimage = Image.new('RGBA', (width, height), bgtext)
    # Render the text.
    textdraw = ImageDraw.Draw(textimage)
    textdraw.text((0,0), text, font=font, fill=fill)
    # Rotate the text image.
    rotated = textimage.rotate(angle, expand=1)
    # Paste the text into the image, using it as a mask for transparency.
    image.paste(rotated, position, rotated)

def getMonthName(monthNumber):
    monthName = 'ERR'
    if monthNumber == '1':
      monthName = "Jan"
    elif monthNumber == '2':
      monthName = "Feb"
    elif monthNumber == '3':
      monthName = " Mar"
    elif monthNumber == '4':
      monthName = "Apr"
    elif monthNumber == '5':
      monthName = " May"
    elif monthNumber == '6':
      monthName = "Jun"
    elif monthNumber == '7':
      monthName = " Jul"
    elif monthNumber == '8':
      monthName = "Aug"
    elif monthNumber == '9':
      monthName = " Sep"
    elif monthNumber == '10':
      monthName = " Oct"
    elif monthNumber == '11':
      monthName = "Nov"
    elif monthNumber == '12':
      monthName = " Dec"

    return  monthName


def setBrightness(value):
    print ("    Updating brightness " + str(value) + "[0-1024]")
    cmd = "gpio -g pwm 18 " + str(value)
    os.system(cmd) # Max brigth 1024

def getEphem():
    global next_sunrise
    global next_sunset
    global lnext_sunrise
    global lnext_sunset
    global next_full_moon
    global next_new_moon
    o=ephem.Observer()
    o.lat=lat
    o.long=long
    s=ephem.Sun()
    s.compute()
    print o
    date_sunrise = str(ephem.localtime(o.next_rising(s))) # Next sunrise
    date_sunset = str(ephem.localtime(o.next_setting(s))) # Next sunset
    next_sunrise = date_sunrise.split(" ",1)[1].split(".",1)[0]
    next_sunset = date_sunset.split(" ",1)[1].split(".",1)[0]
    lnext_sunrise = float(next_sunrise.replace(":", ""))
    lnext_sunset = float(next_sunset.replace(":", ""))
    print next_sunrise
    print next_sunset
    date_full_moon = str(ephem.next_full_moon(o.date))
    date_new_moon = str(ephem.next_new_moon(o.date))
    aux = date_full_moon.split(" ",1)[0]
    next_full_moon = aux.split("/",2)[2]
    # + "/" + aux.split("/",2)[1] + "/" + aux.split("/",1)[0] # If you want to see entire date
    next_full_moon += getMonthName(aux.split("/",2)[1])
    aux = date_new_moon.split(" ",1)[0]
    next_new_moon = aux.split("/",2)[2]
    # + "/" + aux.split("/",2)[1] + "/" + aux.split("/",1)[0] # If you want to see entire date
    next_new_moon += getMonthName(aux.split("/",2)[1])
    print next_new_moon
    print next_full_moon

if __name__ == "__main__":
    last_light = 0
    disp.display()
    aout = 0
    getEphem()
    while True:
        show_time_temp()
        if(L_sensor == 1):
            if YL40: # If YL40 variable set to 1
                print "paso"
                light = 1024 - (read_ain() * 4)
            else: # Your brightness sensor is connected to ADC directly
                adc_light.configure(0)
                light = ((adc_light.read()-100) / 3)
            print("Light: " + str(light) + " Last: " + str(last_light) + " [0-1024]")
            if light > (last_light + 30) or light < (last_light - 30):
                last_light = light
                t = Timer(0, lambda: setBrightness(light))
                t.start()

        time.sleep(1)
