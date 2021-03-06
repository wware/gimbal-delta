#!/usr/bin/env python

import argparse
import os
from ctypes import *

prog = os.path.basename(__file__)
parser = argparse.ArgumentParser(
    prog=prog,
    formatter_class=argparse.RawDescriptionHelpFormatter,
    description=__doc__
)

parser.add_argument('-a',
    type=int, default=0,
    help='motor A',
)
parser.add_argument('-b',
    type=int, default=0,
    help='motor A',
)
parser.add_argument('-c',
    type=int, default=0,
    help='motor A',
)
parser.add_argument('--debug', '-d',
    action='store_true',
    help='turn on debug-level debugging output',
)
parser.add_argument('--duration', '-D',
    type=int, default=300,
    help='turn on debug-level debugging output',
)
opts = parser.parse_args()


os.system("make motor.so")
lib = cdll.LoadLibrary("./motor.so")
lib.run_motors(opts.a, opts.b, opts.c, opts.duration, 1 if opts.debug else 0)
