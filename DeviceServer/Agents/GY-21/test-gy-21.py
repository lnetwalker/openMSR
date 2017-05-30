#!/usr/bin/python
# -*- coding: iso-8859-15 -*-

import gy21

# init device

try:
    T_H_sensor = 1
    print "Checking Temperature/Humidity sensor...",
    obj = gy21.HTU21D()
    print("   Sensor OK!")
except:
    T_H_sensor = 0
    print("   Sensor unplugged!")

temp_C = None
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
