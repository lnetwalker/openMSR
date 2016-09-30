#!/usr/bin/python

# HttpRequestTest
# make a http request to the device server an show the values read
# just to learn how things are done in python
# (c) 2016 by Hartmut Eilers <hartmut@eilers.net>
# released und the terms of the GNU GPL V2.0 or later

# import http library
import requests

Response = requests.get('http://prog.hucky.net:10080/index.html', headers={ "User-Agent": "Mozilla Banana" }, data = {'1':'1'})
#Response = requests.get('http://homecontrol.hucky.net:10080/analog/read.html?1', headers={ "user-agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/49.0.2623.108 Chrome/49.0.2623.108 Safari/537.33" })
print Response.text
