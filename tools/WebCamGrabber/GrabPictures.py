#!/usr/bin/python

# OpenMSR Cam Picture Capture
# captures pictures from a webcamstream
# reads the OpenMSR DeviceServer and captures images
# when a defined I/O pin is high

# Todo: enhance this to work with all 8 Pins of the iogroup with 8 Cams!

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
	Found_url = False
	Found_group = False
	Found_file = False
	NumOfPics = 0
	OldCommand = "00000000"

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
			Found_url = True
 		elif opt in ("-g", "--group"):
 			iogroup = arg
			Found_group = True
		elif opt in ("-f", "--file"):
			conf_file = arg
			Found_file = True

	# the url and the iogroup are mandatory so if one or both are missing stop
	if ( not Found_url or not Found_group ):
		print 'GrabPictures.py -u <URL> -g <iogroup>'
		print 'Missing parameter, both parameters are needed!'
		sys.exit(2)

	# run the loop
	while (True):
		command = ""
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
				if NumOfPics < 10:
					print "Door open, grabbing pictures"
					epoch_time = "{:.9f}".format(time.time())
					# get Date/time
					DateTimeStr = subprocess.check_output(["date", "+DATE: %Y-%m-%d TIME: %H:%M:%S GMT"])

					try:
						# get image
						status = subprocess.call("/usr/bin/wget" + " -q --user=admin --password=secretpassword http://ipcam.hucky.net:8001/snapshot.cgi -O " + epoch_time + '.jpg', shell=True)
						# annotate the grabbed image with date and time
						status = subprocess.call("/usr/bin/convert " + "-font helvetica -fill blue -pointsize 36 -draw 'text 15,50 " + DateTimeStr + "' " + epoch_time + ".jpg"
					except:
						print "Error fetching Cam Picture"

					NumOfPics += 1

			# /if cmd0=1

			if ( ( OldCommand[0] == '1' ) and ( command[0] == '0' ) ):
				# clean up and upload the pictures to server
				print "Door closed now, cleaning up saved images"
				cleanup = True
				NumOfPics = 0

				try:
					status = subprocess.call("scp" + " -P 10022 *.jpg els@www.eilers.net:/var/www/ELS/webcam/DevoloHC", shell=True)
					status = subprocess.call("rm" + " -f ./*.jpg", shell=True)
				except:
					print "Error cleaning up saved images"

			# Save the state
			OldCommand = command
		#/if Response
		Error = False
	#/while
#/main


if __name__ == "__main__":
	main(sys.argv[1:])
