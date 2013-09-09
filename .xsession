function runonce() {
PIDFILE="/tmp/runonce-$USER/${1}.pid"
kill -0 `cat $PIDFILE` > /dev/null
if [ -e "$PIDFILE" ] && kill -0 `cat "$PIDFILE"` &2> /dev/null; then
    return
fi

"$@" &
echo "$!" > $PIDFILE
}

. ~/.session
export _JAVA_AWT_WM_NOREPARENTING=1

xhost local:boinc &
xset r rate 220 &
xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'

nitrogen --restore
dex -e awesome -a &
unagi &
runonce mpd

xautolock -locker lockscreen -corners "0+00" -cornerdelay 1 &

# vim: set filetype=sh :
