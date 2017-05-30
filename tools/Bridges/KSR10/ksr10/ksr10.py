# this file contains the base control set for the KSR10 Robot arm
#
# Written by Niels Bosboom, n.bosboom@gmail.com, july 2012
# (based on ideas provided by http://www.aonsquared.co.uk)

# imports
import usb.core
import time

class ksr10_class:

    def __init__(self):
        self.dev = usb.core.find(idVendor=0x1267, idProduct=0x0000)
        if self.dev is None:
            print "Unable to initialize ksr10..."
        # set status to stop all movement and dim lights        
        self.status = dict()
        self.status["lights"] = 0
        self.stop()

    def sendcommand(self):
        # build command from status
        byte1 = self.status["shoulder"]*64 + self.status["elbow"]*16 + self.status["wrist"]*4 + self.status["grip"]        
        # build command        
        comm_bytes = (byte1, self.status["base"], self.status["lights"])
        # print "commando : ",comm_bytes
        # send command to device
        try:
            self.dev.ctrl_transfer(0x40, 6, 0x100, 0, comm_bytes, 1000)
        except AttributeError:
            print "KSR10 is not connected..."

    def lights(self):
        # swap lights
        if (self.status["lights"]== 0):
            self.status["lights"] = 1
        else:
            self.status["lights"] = 0
        #send command
        self.sendcommand()
    
    def move(self,part,direction):
        #determine which part to move:        
        
        # determine direction
        if (direction=='right') or (direction=='up') or (direction=='close'):
            dir_command = 1
        elif (direction=='left') or (direction=='down') or (direction=='open'):
            dir_command = 2
        else:
            dir_command = 0        
        self.status[part] = dir_command
        
        # send command
        self.sendcommand()
        
    def stop(self):
        # stop all movement and dim lights        
        self.status["shoulder"] = 0
        self.status["base"] = 0
        self.status["elbow"] = 0
        self.status["wrist"] = 0
        self.status["grip"] = 0
        # send command
        self.sendcommand()

if __name__ == '__main__':
    print "No main in this module"
    