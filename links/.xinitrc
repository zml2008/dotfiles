
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi


[ -z "$1" ] && WM="i3" || WM="$1"
echo $WM
export _JAVA_AWT_WM_NOREPARENTING=1

. ~/.xprofile

exec $WM

# vim: set filetype=sh :
