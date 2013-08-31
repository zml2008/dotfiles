
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi


[ -z "$1" ] && WM="awesome" || WM="$1"
echo $WM
export _JAVA_AWT_WM_NOREPARENTING=1

. ~/.xsession

exec $WM

# vim: set filetype=sh :
