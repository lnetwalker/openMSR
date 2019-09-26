# https://stackoverflow.com/questions/276052/how-to-get-current-cpu-and-ram-usage-in-python
import os

def get_cpu_load():
    """ Returns a list CPU Loads"""
    result = []
    cmd = "WMIC CPU GET LoadPercentage "
    response = os.popen(cmd + ' 2>&1','r').read().strip().split("\r\n")
    for load in response[1:]:
       result.append(int(load))
    return result

if __name__ == '__main__':
    print get_cpu_load()
