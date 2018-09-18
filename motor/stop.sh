#!/bin/bash

for x in $(ps ax | grep testmotor.py | grep -v grep | cut -c -6); do
	kill -9 $x
done
