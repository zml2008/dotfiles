# Variable definitions & assorted preferences
export PATH="$HOME/bin:$PATH"
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel"
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
autoload colors && colors

# Set the editor
export VLESS=$(find /usr/share/vim -name 'less.sh')
if [ ! -z $VLESS ]; then
    alias less=$VLESS
fi
export EDITOR="/usr/bin/vim"
# Source the aliases configuration
. ~/.aliases

setopt autocd extendedglob
# bindkey -e
# The following lines were added by compinstall
zstyle :compinstall filename '/home/zach/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

if [ "$TERM" = "st-256color" ]; then
    function zle-line-init () { echoti smkx }
    function zle-line-finish () { echoti rmkx } 
    zle -N zle-line-init
    zle -N zle-line-finish
fi

# SSH stuff
eval $(keychain --eval --agents ssh -Q --quiet id_rsa)
if [ -n "$SSH_CONNECTION" ]; then
    typeset -A POWERLINE_CONFIG
    POWERLINE_CONFIG=("common.dividers.left.soft" "<" "common.divders.left.hard" "" "common.dividers.right.soft" ">" "common.dividers.right.hard" "")    
fi

# Prompt fancification
if [ -e /usr/share/zsh/site-contrib/powerline.zsh ]; then
. /usr/share/zsh/site-contrib/powerline.zsh
else
    PS1="$fg[blue][\u@\h:$fg[yellow]\W$fg[blue]]$reset"
fi

# Intro message
echo -e "$fg[magenta]$(fortune -s | cowsay -s -W60)$reset_color"

