#!/bin/bash
echo "Testmessage"
# this script is used to call digitemp and format the output
# that can be used by PhysMach
# (c) 2008 by Hartmut Eilers
# licensed under the GNU GPL V2

# call digitemp , just take the last 2 sensors, just the temp in C, remove cr lf, remove the decimalpoint
# resulting in a multiplication with 100
# 35.26 degree celsius are returned as 3526
result=`/usr/bin/digitemp_DS9097  -a| tail -n 2|cut -d " " -f 7|sed 's/^M/ /'|sed 's/\.//' `
echo $result
