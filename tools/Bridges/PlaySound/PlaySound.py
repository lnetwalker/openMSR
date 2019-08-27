#!/usr/bin/python

# OpenMSR Utility to play sounds on signals
# reads the OpenMSR DeviceServer an plays sounds
# when a defined I/O pin is high

# import http library
import requests

# import useful stuff
import sys, getopt, time, subprocess, ConfigParser
from array import array
import pygame


def main(argv):

	def strip_html( raw ):
		# strip off html stuff of OpenMSR IOgroup read answer
		# and returns a String with the pure ones and zeros of
		# the corresponding IOGroup
		bare=raw.replace("<html><body>","")
		bare=bare.replace("</body></html>","")
		bare=bare.replace(" ","")
		return bare

	def play_sound( soundfile ):
		# plays a soundfile
		print ("Playing " + soundfile)
		s = pygame.mixer.Sound( soundfile )
		s.play()
		while pygame.mixer.get_busy() == True:
			# print "waiting"
			# pygame.time.wait(5000)
			continue
		return

	URL = ''
	iogroup = ''
	Found_url = False
	Found_group = False
	pygame.mixer.init(frequency=11025, size=-8, channels=1, buffer=4096)

	# get the commandline parameters
	try:
		opts, args = getopt.getopt(argv,"hu:g:f:",["url=","group=", "file="])
	except getopt.GetoptError:
		print ('PlaySound.py -u <URL> -g <iogroup> -f <configfile>')
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

	# the url and the iogroup are mandatory so if one or both are missing stop
	if ( not Found_url or not Found_group or not Found_file):
		print ('PlaySound.py -u <URL> -g <iogroup> -f <configfile>')
		print ('Missing parameter, all parameters are needed!')
		sys.exit(2)

	# read the config file
	Config = ConfigParser.ConfigParser()
	Config.read(conf_file)
	sound = {}
	pin = {}
	edge = {}
	OldPinState = strip_html("00000000")

	# get sections of Config
	ConfigSections = Config.sections()
	# build conf variables which hold all needed Data
	confCounter = 1
	for ConfigSection in ConfigSections:
		sound[confCounter] = Config.get ( ConfigSection, 'Sound' )
		pin[confCounter] = Config.get ( ConfigSection, 'Pin' )
		edge[confCounter] = Config.get ( ConfigSection, 'Edge' )
		print ("Conf Counter : " , confCounter , " Found Sound: " + sound[confCounter] + " Pin: " + pin[confCounter] + " Edge: " + edge[confCounter] + " in Section: " + ConfigSection)
		confCounter += 1


	# run the loop
	while (True):
		command = ""
		Error = False

		try:
			Response = requests.get(URL + '?' + iogroup)
		except:
			print ("Error reading DeviceServer")
			Error = True

		if ( ( Response != "<Response [200]>" ) or ( Error == False ) ):
			command = strip_html(Response.text)
			# loop over the configured pins
			for current in range(1,len(sound)+1):
				print ("DeviceServer: " + command + " current " , current, " " + command[0])
				# play sound if edge condition matches
				# Hi state
				if edge[current] == "+" and command[int(pin[current])] =="1" and OldPinState[int(pin[current])] == "0":
					play_sound (sound[current])

				# falling edge
				elif edge[current] == "-" and command[int(pin[current])] =="0" and OldPinState[int(pin[current])] == "1":
					play_sound (sound[current])

				# lo state
				elif edge[current] == "0" and command[int(pin[current])] =="0":
					play_sound (sound[current])

				# rising edge
				elif  edge[current] == "1" and command[int(pin[current])] =="1":
					play_sound (sound[current])

			#/for current ...

			# Save the pinstate for next run and edge detection
			OldPinState = command

		#/if Response
		Error = False
	#/while
#/main


if __name__ == "__main__":
	main(sys.argv[1:])
