#!/bin/sh
ifconfig en1 inet | sed -e '1d' -e 's/^.*inet\ //' -e 's/\ netmask.*$//'
