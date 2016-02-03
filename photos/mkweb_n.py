#!/usr/bin/python
import os, sys

##############################################################################
# This script forks n processes to resize the images into webpage resolution
# Requirement:
#   mkweb.pl, imagemagick, and a lot of PNG or TIFF files to process
#
# Usage:
#   mkweb_n.py n [-b] *.tif
#     n : number of processes
#     -b: is the option to pass to mkweb.pl
#
# Author: Tuan T. Pham <tuan at vt dot edu>
# https://github.com/neofob/PersonalTools.git

# set this to something else to turn off the debug messages
OUTPUT = False

def DEBUG(arg):
  if OUTPUT:
    print arg

# main function
if __name__ == '__main__':
  length = len(sys.argv)
  DEBUG('length = ' + str(length))
  n_procs = int(sys.argv[1])
  DEBUG(n_procs)
  if n_procs < 1:
    sys.exit(1)

  opt = sys.argv[2]
  if "-b" != opt:
    opt = ""
    start_index = 2
  else:
    start_index = 3

  DEBUG('opt = ' + opt)
  mArray = []
  pivot = start_index
  part_size = (length-start_index)/n_procs
  pid_array = []
  DEBUG(str(pid_array))
  for i in range(0, n_procs):
    tmp = [opt] + sys.argv[pivot:part_size*(i+1) + start_index]
    DEBUG('tmp = ' + str(tmp))
    mArray.append(tmp)
    pivot = pivot + part_size

  # fill the remaining files starting from process 0
  tmp = sys.argv[pivot:]
  for i in range(0, len(tmp)):
    mArray[i].append(tmp[i])

  for i in range(0, n_procs):
    pid = os.fork()
    if ((0 == pid) and (0 != mArray[i].__len__())):
      DEBUG('executing ' + 'mkweb.pl' + str(mArray[i]))
      os.execvp("mkweb.pl", ['mkweb.pl'] + mArray[i])
      sys.exit(0)
    else:
      pid_array.append(pid)

  # if we exit here, we will kill all child processes
  for i in range(0, n_procs):
    os.waitpid(pid_array[i], 0)
  print "Exiting..."
