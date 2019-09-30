#!/bin/bash

# this script is used to gather data of the host running the Deviceserver
# as an example the load and the amount of free space on / is shown
# can be used by PhysMach
# (c) 2016 by Hartmut Eilers
# licensed under the GNU GPL V2

# get the 1 minute load and multiply by 100
load_1min=`top -b -n1|head -n1|cut -d " " -f14|sed 's/\.//ig'|sed 's/,//ig'`;

# alternative you can use the following cmd to get the int(1 minute load)
# top -n1|head -n1|cut -d " " -f12|cut -d "." -f1

diskfree=`df -kh |egrep "/$" |head -n1|tr -s " "|cut -d " " -f5|sed 's/%//ig'`;

echo $load_1min $diskfree|sed 's/,//'
