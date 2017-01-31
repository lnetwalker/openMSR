#!/usr/bin/python

# OpenMSR Cam Picture Capture
# captures pictures from a webcamstream
# reads the OpenMSR DeviceServer an captures images
# when a defined I/O pin is high

# import http library
import requests

# import useful stuff
import sys, getopt, time, subprocess

def main(argv):

	def strip_html( raw ):
		# strip off html stuff of OpenMSR IOgroup read answer
		# and returns a String with the pure ones and zeros of
		# the corresponding IOGroup
		bare=Response.text.replace("<html><body>","")
		bare=bare.replace("</body></html>","")
		bare=bare.replace(" ","")
		return bare

	URL = ''
	iogroup = ''
	# get the commandline parameters
	try:
		opts, args = getopt.getopt(argv,"hu:g:",["url=","group="])
	except getopt.GetoptError:
		print 'GrabPictures.py -u <URL> -g <iogroup>'
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			print 'GrabPictures.py -u <URL> -g <iogroup>'
			sys.exit()
		elif opt in ("-u", "--url"):
			URL = arg
 		elif opt in ("-g", "--group"):
 			iogroup = arg



	# run the loop
	while (True):
		command = ""
		DoorState = "0"
		NumOfPics=0
		Error = False

		try:
			Response = requests.get(URL + '?' + iogroup)
		except:
			print "Error reading DeviceServer"
			Error = True

		if ( ( Response <> "<Response [200]>" ) or ( Error == False ) ):
			command = strip_html(Response.text)
			#print "Data read from server: " + command
			if command[0] == "1":
				print "Door open, grabbing pictures"
				epoch_time = "{:.9f}".format(time.time())
				#print (epoch_time)
				if ( NumOfPics < 10 ):
					try:
						status = subprocess.call("/usr/bin/wget" + " -q --user=admin --password=security4hucky http://ipcam.hucky.net:8001/snapshot.cgi -O " + epoch_time + '.png', shell=True)
						NumOfPics += 1
					except:
						print "Error fetching Cam Picture"

			# /if cmd0=1

			if ( ( DoorState == "1" ) and ( command[0] == "0" ) ):
				# clean up and upload the pictures to server
				print "Door closed now, cleaning up saved images"
				cleanup = True
				NumOfPics = 0
				try:
					status = subprocess.call("scp" + " -P 10022 *.png els@www.eilers.net:/var/www/ELS/webcam/DevoloHC", shell=True)
					status = subprocess.call("rm" + " -f ./*.png", shell=True)
				except:
					print "Error cleaning up saved images"
			# Save the state
			DoorState = command[0]
		#/if Response
		Error = False
	#/while
#/main


if __name__ == "__main__":
	main(sys.argv[1:])
