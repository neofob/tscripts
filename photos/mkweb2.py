#!/usr/bin/python
import os, sys
# this script assumes that you have 2 cores
# dcraw

# main function
if __name__ == '__main__':
	len = len(sys.argv)
	print len
	list0 = ['-b'] + sys.argv[1:(len/2)+1]
	list1 = ['-b'] + sys.argv[(len/2)+1:]
	print list0
	print list1
	pid = os.fork()
	if ((pid != 0) and (list0.__len__() != 0)):
		os.execvp("mkweb.pl", ['mkweb.pl'] + list0)
	pid = os.fork()
	if ((pid != 0) and (list1.__len__() != 0)):
		os.execvp("mkweb.pl", ['mkweb.pl'] + list1)
	print "Exiting..."
