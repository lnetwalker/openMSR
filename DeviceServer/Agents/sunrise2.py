# sunrise / sunset in the openMSR environment for any place in the world
# because I wanted a solution which is free of any configuration

# if you run sunrise2.py without parameters it will print just two values
# for sunrise and sunset. 1 if in this current minute is sunrise/sunset
# otherwise it will print 0
# for debugging purpose you have the flags -d or --debug, which will
# print information the script gathers about your location and the
# sunrise/sunset times for your location.

# I compiled this from the following sources and would like to thank the
# people who shared their work and knowledge with the rest of us:

# I combined some tools:

# first, you need to know where you are on earth to calculate sunset/sunrise.
# normally you use longitude and latitude to describe your location.
# calculate the sunrise/sunset from longitude and latitude
# https://steemit.com/steemstem/@procrastilearner/killing-time-with-recreational-math-calculate-sunrise-and-sunset-times-using-python

# you can get this values from your external IP address, so I searched
# for tools to determine the external IP.
# https://stackoverflow.com/questions/2311510/getting-a-machines-external-ip-address-with-python
# see the post from mario1ua

# with your IP address you can query different services to find latitude and longitude
# https://pypi.org/project/ip2geotools/

# everything put together you have a nifty tool which automatically calculates
# the sunrise / sunset

# the timedifference for my current location between the manual set long and lat
# compared to the automated calculated values is just 1 minute. For me this is
# precise enough.

# **************************************************************************
# This code is released by Procrastilearner under the CC BY-SA 4.0 license.
#
# Source for the sunrise calculation:
#     https://en.wikipedia.org/wiki/Sunrise_equation
# **************************************************************************
import time
import math
import math
import sys, getopt

def main(argv):
    # from: https://github.com/MrMinimal64/timezonefinder/blob/master/example.py
    # Getting a location's time zone offset from UTC in minutes:
    # adapted solution from https://github.com/communikein and `phineas-pta <https://github.com/phineas-pta>`__
    from datetime import datetime
    from pytz import timezone, utc
    from timezonefinder import TimezoneFinder

    def get_offset(*, lat, lng):
        """
        returns a location's time zone offset from UTC in minutes.
        """

        tf = TimezoneFinder()
        today = datetime.now()
        tz_target = timezone(tf.certain_timezone_at(lng=lng, lat=lat))
        # ATTENTION: tz_target could be None! handle error case
        today_target = tz_target.localize(today)
        today_utc = utc.localize(today)
        return (today_utc - today_target).total_seconds() / 3600
    # EOF get_offset

    def date_to_jd(year,month,day):
        # Convert a date to Julian Day.
        # Algorithm from 'Practical Astronomy with your Calculator or Spreadsheet',
        # 4th ed., Duffet-Smith and Zwart, 2011.
        # This function extracted from https://gist.github.com/jiffyclub/1294443
        if month == 1 or month == 2:
            yearp = year - 1
            monthp = month + 12
        else:
            yearp = year
            monthp = month
        # this checks where we are in relation to October 15, 1582, the beginning
        # of the Gregorian calendar.
        if ((year < 1582) or
            (year == 1582 and month < 10) or
            (year == 1582 and month == 10 and day < 15)):
            # before start of Gregorian calendar
            B = 0
        else:
            # after start of Gregorian calendar
            A = math.trunc(yearp / 100.)
            B = 2 - A + math.trunc(A / 4.)

        if yearp < 0:
            C = math.trunc((365.25 * yearp) - 0.75)
        else:
            C = math.trunc(365.25 * yearp)
            D = math.trunc(30.6001 * (monthp + 1))
            jd = B + C + D + day + 1720994.5
        return jd
    # end of date_to_jd

    # autodetect the geo location
    # inserted ...
    # first get our external ip

    # This example requires the requests library be installed.  You can learn more
    # about the Requests library here: http://docs.python-requests.org/en/latest/

    from requests import get

    ip = get('https://api.ipify.org').text

    # EOF get ip

    # now determine the location from the IP address

    from ip2geotools.databases.commercial import IpInfo
    response = IpInfo.get(ip, api_key='free')
    latitude_deg = response.latitude
    longitude_deg = response.longitude

    # EOF geolication on ip
    # now we need to find the time difference to UTC for our current location:

    # from: https://github.com/MrMinimal64/timezonefinder/blob/master/example.py
    # Getting a location's time zone offset from UTC in minutes:

    mylocation = {'lat': latitude_deg, 'lng': longitude_deg}
    timezone = get_offset(**mylocation)

    # end of mods for autodetection

    # get the commandline parameters
    Debug = False
    try:
        opts, args = getopt.getopt(sys.argv[1:], ":d",["debug"])
    except getopt.GetoptError:
        print ('sunrise2.py -d')
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-d","--debug"):
            Debug = True

    import datetime

    pi=3.14159265359

    latitude_radians = math.radians(latitude_deg)
    longitude__radians = math.radians(longitude_deg)

    jd2000 = 2451545 #the julian date for Jan 1 2000 at noon

    currentDT = datetime.datetime.now()
    current_year = currentDT.year
    current_month = currentDT.month
    current_day = currentDT.day
    current_hour = currentDT.hour

    jd_now = date_to_jd(current_year,current_month,current_day)

    n = jd_now - jd2000 + 0.0008

    jstar = n - longitude_deg/360

    M_deg = (357.5291 + 0.98560028 * jstar)%360
    M = M_deg * pi/180

    C = 1.9148 * math.sin(M) + 0.0200 * math.sin(2*M) + 0.0003 * math.sin(3*M)

    lamda_deg = math.fmod(M_deg + C + 180 + 102.9372,360)

    lamda = lamda_deg * pi/180

    Jtransit = 2451545.5 + jstar + 0.0053 * math.sin(M) - 0.0069 * math.sin(2*lamda)

    earth_tilt_deg = 23.44
    earth_tilt_rad = math.radians(earth_tilt_deg)

    sin_delta = math.sin(lamda) * math.sin(earth_tilt_rad)
    angle_delta = math.asin(sin_delta)

    sun_disc_deg =  -0.83
    sun_disc_rad = math.radians(sun_disc_deg)

    cos_omega = (math.sin(sun_disc_rad) - math.sin(latitude_radians) * math.sin(angle_delta))/(math.cos(latitude_radians) * math.cos(angle_delta))

    omega_radians = math.acos(cos_omega)
    omega_degrees = math.degrees(omega_radians)

    Jrise = Jtransit - omega_degrees/360
    numdays = Jrise - jd2000
    numdays =  numdays + 0.5 #offset because Julian dates start at noon
    numdays =  numdays + timezone/24 #offset for time zone
    sunrise = datetime.datetime(2000, 1, 1) + datetime.timedelta(numdays)

    Jset = Jtransit + omega_degrees/360
    numdays = Jset - jd2000
    numdays =  numdays + 0.5 #offset because Julian dates start at noon
    numdays =  numdays + timezone/24 #offset for time zone
    sunset = datetime.datetime(2000, 1, 1) + datetime.timedelta(numdays)

    #Output section
    if  Debug:
        print("------------------------------")
        print("Today's date is " + currentDT.strftime("%Y-%m-%d"))
        print("------------------------------")
        #("%Y-%m-%d %H:%M")
        print ("IP address = ", ip)

        print("Latitude =  " + str(latitude_deg))
        print("Longitude = " + str(longitude_deg))
        print("Timezone =  " + str(timezone))
        print("------------------------------")
        print("Sunrise is at " + sunrise.strftime("%H:%M"))
        print("------------------------------")
        print("Sunset is at  " + sunset.strftime("%H:%M"))
    else:
        currentTime=datetime.datetime.now()
        if currentTime.strftime("%H:%M") == sunrise.strftime("%H:%M"):
            ItsSunrise = "1"
        else:
            ItsSunrise = "0"
        if currentTime.strftime("%H:%M") == sunset.strftime("%H:%M"):
            ItsSunset = "1"
        else:
            ItsSunset = "0"
        print(ItsSunrise,ItsSunset)

if __name__ == "__main__":
	main(sys.argv[1:])
