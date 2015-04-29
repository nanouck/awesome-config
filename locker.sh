#!/bin/bash

exec xautolock -detectsleep \
  -time 15 -locker "gnome-screensaver-command --lock" \
  -notify 30 \
  -notifier "notify-send -u normal -t 10000 -- 'LOCKING screen in 30 seconds'"
