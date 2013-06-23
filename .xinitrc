. /home/zach/.bash_profile

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

export _JAVA_AWT_WM_NOREPARENTING=1

xhost local:boinc &
xset r rate 220 &
xmodmap -e 'clear Lock'-e 'keycode 0x32 = Escape'

exec startup-ctl
#exec /usr/lib/systemd/systemd --user

# vim: set filetype=sh :
