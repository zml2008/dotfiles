. /home/zach/.bash_profile

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

xhost local:boinc &
xset r rate 220 &
exec systemd --user
