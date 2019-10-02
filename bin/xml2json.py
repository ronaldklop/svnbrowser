#! /usr/bin/env python

import sys
import json
from xmljson import badgerfish as xml
from xml.etree.ElementTree import fromstring

f = open(sys.argv[1], "rb")
buf = f.read()
str = buf.decode("utf-8")
xmlstr = fromstring(str)
xmldata = xml.data(xmlstr)
dmp = json.dumps(xmldata, indent=1)

print(dmp)
