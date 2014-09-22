#!/bin/bash

nb_display=$(xrandr -q |grep -w connected| wc -l)

if [ "$(hostname -s)" == "RENNDLXRDL3733" ]; then
    if [ $nb_display -eq 2 ]; then
	xrandr --output DP-1 --mode 1680x1050 --primary --preferred --output DP-2 --mode 1920x1080 --right-of DP-1
    else
	xrandr --output DP-1 --mode 1680x1050 --primary --preferred --output DP-2 --off
    fi

elif [ "$(hostname -s)" == "renndlxrdp0201" ]; then
    if [ $nb_display -eq 2 ]; then
	xrandr --output HDMI1 --mode 1920x1080 --primary --preferred --output VGA1 --mode 1680x1050 --right-of HDMI1
    else
	xrandr --output HDMI1 --mode 1920x1080 --primary --preferred --output VGA1 --off
    fi
else
    # home
    xrandr --output DVI-D-0 --mode 1920x1080 --primary --preferred --right-of VGA-0 --output VGA-0 --mode 1680x1050
fi
