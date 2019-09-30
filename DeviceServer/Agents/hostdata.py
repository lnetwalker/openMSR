#!/usr/bin/python3
# https://stackoverflow.com/questions/276052/how-to-get-current-cpu-and-ram-usage-in-python

import os
from sys import platform as _platform
import sys

def get_cpu_load():
    """ Returns a list CPU Loads"""
    result = ''
    cmd = "cmd /C WMIC CPU GET LoadPercentage "
    response = os.popen(cmd + ' 2>&1','r').read().strip().split("\r\n")
    for load in response[1:]:
        result=load
    return result

def get_free_disk():
    """ Returns a list CPU Loads"""
    result = ''
    cmd = "cmd /C WMIC VOLUME GET FreeSpace "
    response = os.popen(cmd + ' 2>&1','r').read().strip().split("\r\n")
    for load in response[1:]:
        result=load
    return result

if __name__ == '__main__':
    if _platform == "linux" or _platform == "linux2":
        # linux
        response=os.popen('./Agents/hostdata.sh').read()
        sys.stdout.write(response)
    elif _platform == "win32" or _platform == "win64":
        # Windows CPU usage multiplied by 100 because frontend divides by 100
        # free Diskspace in GB
        sys.stdout.write(get_cpu_load()*100+' '+int(get_free_disk()/1024/1024/1024))
