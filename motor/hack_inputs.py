#!/usr/bin/env python

import os
from inputs import get_key
from ctypes import cdll

shutdown_sequence = [
    'KEY_3', 'KEY_1', 'KEY_4', 'KEY_1',
    'KEY_5', 'KEY_9', 'KEY_2', 'KEY_6'
]

sequence = []
done = False
action = None

os.system("make motor.so")
lib = cdll.LoadLibrary("./motor.so")

SPEED = 40000
DURATION = 400

funcdct = {
    'KEY_J': (SPEED,  0,      0,      DURATION, 0),
    'KEY_K': (-SPEED, 0,      0,      DURATION, 0),
    'KEY_N': (0,      SPEED,  0,      DURATION, 0),
    'KEY_M': (0,      -SPEED, 0,      DURATION, 0),
    'KEY_G': (0,      0,      SPEED,  DURATION, 0),
    'KEY_H': (0,      0,      -SPEED, DURATION, 0)
}

while not done:
    events = get_key()
    for event in events:
        if event.ev_type != 'Key':
            continue
        if event.code == 'KEY_Q':
            done = True
            break
        if event.state == 1:
            sequence.append(event.code)
        sequence = sequence[-8:]
        if sequence == shutdown_sequence:
            print('SHUTTING DOWN THE RASPBERRY PI')
            os.system("sudo shutdown -h now")
        if event.state == 0:
            action = None
        else:
            action = funcdct.get(event.code)
        if action is not None:
            lib.run_motors(*action)
