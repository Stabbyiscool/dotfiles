#!/bin/bash

sh -c '/usr/bin/activate-linux & sleep 0.3 && /usr/bin/wayfreeze --after-freeze-cmd "/usr/bin/grim -g \"\$(/usr/bin/slurp)\" - | /usr/bin/wl-copy; killall wayfreeze; killall activate-linux"'