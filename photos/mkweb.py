#!/usr/bin/python
__author__ = "Tuan T. Pham"
__version__ = "0.0.1"

"""
    mkweb.py resizes a bunch of big image files to web-friendly size.
    The default settings are stored in $HOME/.config/image/image.cfg
   :copyright: (c) 2014 by Tuan T. Pham
"""

try:
    import ConfigParser as configparser
except ImportError:
    import configparser

import os
import sys
import glob
import string
import re
import PythonMagick as Magick
import multiprocessing
from multiprocessing import Process
from optparse import OptionParser

OUTPUT = False
DRY_RUN = False
CONFIG_FILE = 'image.cfg'
DEFAULT_DIR = '.config/image'

def DEBUG(arg):
    if OUTPUT:
        print arg

image_defaults = {
    'scale' : '1080x1080',
    'quality' : 95,
    'sharpen' : '1x1',
    'type' : 'JPG',
    'profile' : 'strip',
    'fmatch' : ['*.TIF', '*.tif', '*.JPG'],
}
image_settings = dict()

def parse_config(config_file):
    parser = configparser.ConfigParser()
    parser.read(config_file)

    settings = dict()

    # parsing string
    for entry in ('scale', 'type', 'profile', 'sharpen'):
        try:
            settings[entry] = parser.get('Image', entry)
            DEBUG("%s=%s" % (entry, settings[entry]))
        except configparser.NoOptionError:
            pass
        except configparser.NoSectionError:
            break

    # parsing int
    settings['quality'] = parser.getint('Image', 'quality')

    # parsing file match pattern
    pattern = parser.get('Image', 'fmatch')
    DEBUG(pattern)
    settings['fmatch'] = pattern.split(', ')

    return settings

def load_config(config_file):
    print ('config file = %s' % config_file)
    global image_settings
    image_settings = parse_config(config_file)

    print "image settings:"
    for key in image_settings:
        print "%s = %s" % (key, image_settings[key])

def process_dirs(dirs):
    global DRY_RUN
    if DRY_RUN:
        print "\nDRY-RUN: no image will be processed!\n"

    CWD = os.getcwd()
    fileList = []
    for item in dirs:
        os.chdir(item)
        wd = os.getcwd()
        files = []
        for pattern in image_settings['fmatch']:
            files +=glob.glob(pattern)

        for aFile in files:
            fileList += [wd + '/' + aFile]
        os.chdir(CWD)

    # Distribute the big list to all the threads
    thread_no = multiprocessing.cpu_count()
    print "Number of threads = %d" % thread_no
    print "Total files to process = %d" % len(fileList)
    procs = []
    pivot = 0
    part_size = len(fileList)/thread_no
    args_array = []
    for i in range(thread_no):
        args_array.append(fileList[pivot:part_size*(i+1)])
        pivot += part_size

    remain = fileList[pivot:]
    for i in range(len(remain)):
        args_array[i].append(remain[i])

    for i in range(thread_no):
        procs.append(Process(target=process_image, args=(args_array[i],)))
        procs[i].start()

    # The first spawned threads tend to have more work. So we wait
    # for the last threads first because they tend to finish first.
    for i in range(thread_no):
        DEBUG("joining thread %d" % (thread_no-i-1))
        procs[thread_no-i-1].join()

    os.chdir(CWD)

def process_image(images):
    DEBUG(images)
    img = Magick.Image()
    radius, sigma = [float(s) for s in image_settings['sharpen'].split('x')]

    global DRY_RUN

    for item in images:
        try:
            img.read(item)
        except:
            print >> sys.stderr, 'Fail to open %s' % item
            continue
        if DRY_RUN:
            print "Open %s file" % (item)
            continue

        img.scale(image_settings['scale'])
        img.sharpen(radius, sigma)
        img.quality(image_settings['quality'])
        if 'strip' == image_settings['profile']:
            img.strip()
        item = string.replace(item, re.search('\.[^\.]+$', item).group(0), '.jpg')
        img.write(item)


def add_flags(parser):
    parser.add_option("-v", "--version",
                        action="store_true", dest="show_version", default=False,
                        help="show version number and exit")

    parser.add_option("-D", "--debug",
                        action="store_true", dest="show_debug", default=False,
                        help="show debug info")

    parser.add_option("-d", "--dry-run",
                        action="store_true", dest="dry_run", default=False,
                        help="don't do anything, just print commands")

    parser.add_option("-c", "--config",
                        type="string", dest="config_file",
                        help="set config file location (default: %s)" %
                            ("~/" + DEFAULT_DIR + '/' + CONFIG_FILE))


def parse_args():
    parser = OptionParser(usage="%prog [-c CONFIG_FILE] [INPUT_DIRS...]",
                            epilog="Author: Tuan T. Pham <tuan at vt dot edu>")
    add_flags(parser)
    (opts, args) = parser.parse_args()
    if opts.show_version:
        print ('mkweb v%s' % __version__)
        exit(0)

    if opts.show_debug:
        global OUTPUT
        OUTPUT = True

    if opts.dry_run:
        global DRY_RUN
        DRY_RUN = True

    load_config(opts.config_file or
                os.path.expanduser('~/%s/%s' % (DEFAULT_DIR, CONFIG_FILE)))

    return args


if __name__ == '__main__':
    args = parse_args()
    process_dirs(args)
