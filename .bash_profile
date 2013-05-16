#
# ~/.bash_profile
#
export PATH="$HOME/bin:$PATH"
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel"
[[ -f ~/.bashrc ]] && . ~/.bashrc
