import os
import urllib.request

urlResponse = urllib.request.urlopen("http://www.python.org")
urlbytes = urlResponse.read()

contentStr = urlbytes.decode("utf8")
urlResponse.close()
f = open('myfile.txt', 'w')
f.write(contentStr)
f.close()
print(contentStr)