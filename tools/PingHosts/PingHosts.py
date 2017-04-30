#!/usr/bin/python

# OpenMSR Utility to ping hosts and set signals
# in the OpenMSR DeviceServer depending wether
# a host is reachable or not

# import http library
import requests

# import useful stuff
import sys, getopt, time, subprocess, ConfigParser
from array import array
import os, platform


def main(argv):

	def strip_html( raw ):
		# strip off html stuff of OpenMSR IOgroup read answer
		# and returns a String with the pure ones and zeros of
		# the corresponding IOGroup
		bare=raw.replace("<html><body>","")
		bare=bare.replace("</body></html>","")
		bare=bare.replace(" ","")
		return bare

	def ping(host):
		# Returns True if host responds to a ping request
		# Ping parameters as function of OS
		if  platform.system().lower()=="windows":
			ping_str = "-n 1"
			IOredir = ""
		else:
			ping_str = "-c 1"
			IOredir = " >/dev/null"
		# Ping
		return os.system("ping " + ping_str + " " + host + IOredir) == 0

	URL = ''
	conf_file = ''
	iogroup = ''
	Found_url = False
	Found_group = False
	Debug = False
	host = {}
	pin = {}
	PingState = {}

  	# get the commandline parameters
	try:
		opts, args = getopt.getopt(argv, "dhugf:",["url=","group=", "file="])
	except getopt.GetoptError:
		print ('PingHosts.py -u <URL> -g <iogroup>  -f <configfile>')
		sys.exit(2)
	for opt, arg in opts:
 		if opt == '-h':
			print ('PlaySound.py -u <URL> -g <iogroup> -f <configfile>')
			sys.exit()
		elif opt in ("-u", "--url"):
			URL = arg
			Found_url = True
		elif opt in ("-g", "--group"):
			iogroup = arg
			Found_group = True
		elif opt in ("-f", "--file"):
			conf_file = arg
			Found_file = True
		elif opt in ("-d", ""):
			Debug = True

  	# read the config file
	if conf_file == '':
		print ('Error: Config filename needed!')
		print ('PlaySound.py -u <URL> -g <iogroup> -f <configfile>')
		sys.exit(2)

	Config = ConfigParser.ConfigParser()
	Config.read(conf_file)

  	# get sections of Config
	ConfigSections = Config.sections()

	# get general settings of DeviceServer
	if not Found_url:
		URL =  Config.get ( 'DeviceServer', 'URL' )
		if URL != '':
			Found_url = True
	if not Found_group:
		iogroup = Config.get ( 'DeviceServer', 'IOgroup' )
		if iogroup != '':
			Found_group = True

  	# the url, the iogroup and file are mandatory so if one is missing stop
	if ( not Found_url or not Found_group or not Found_file):
		print ('PingHosts.py -u <URL> -g <iogroup> -f <configfile>')
		print ('Missing parameter, -f is mandantory, rest can be configured in file')
		sys.exit(2)

  	# build conf variables which hold all needed Data
	confCounter = 1
	for ConfigSection in ConfigSections:
		if ConfigSection != 'DeviceServer':
			host[confCounter] = Config.get ( ConfigSection, 'Host' )
			pin[confCounter] = Config.get ( ConfigSection, 'Pin' )
			if Debug:
				print ("Conf Counter : " , confCounter , " Found Host: " + host[confCounter] + " Pin: " + pin[confCounter]  + " in Section: " + ConfigSection)
			confCounter += 1

  	# run the loop
	while (True):

		Error = False
  		# loop over the configured hosts
		for current in range(1,len(host)+1):
  			# save Hoststate true if host is reachable
			pingresult = ping (host[current])
			if pingresult:
				PingState[current-1] = "1" # PingState[current-1] minus one because PingState Array starts with 0 !
			else:
				 PingState[current-1] = "0"
			if Debug: print URL + '?' + iogroup + ',' + pin[current] + ',' + PingState[current-1]
			try:
				Response = requests.get(URL + '?' + iogroup + ',' + pin[current] + ',' + PingState[current-1])
			except:
				Error = True

			if Error:
				print "Error write URL " + URL + '?' + iogroup
  		#/for current ...


		# write the results to DeviceServer

	#/while
#/main

if __name__ == "__main__":
	main(sys.argv[1:])
