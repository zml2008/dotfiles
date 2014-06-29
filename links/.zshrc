# Variable definitions & assorted preferences
. ~/.session

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
autoload colors && colors

case "$TERM" in
    st-256color)
        function zle-line-init () { echoti smkx }
        function zle-line-finish () { echoti rmkx } 
        zle -N zle-line-init
        zle -N zle-line-finish
        ;;
    linux)
        # Colors from http://git.sysphere.org/dotfiles/tree/zshrc
         echo -en "\e]P01e2320" # zenburn black (normal black)
         echo -en "\e]P8709080" # bright-black  (darkgrey)
         echo -en "\e]P1705050" # red           (darkred)
         echo -en "\e]P9dca3a3" # bright-red    (red)
         echo -en "\e]P260b48a" # green         (darkgreen)
         echo -en "\e]PAc3bf9f" # bright-green  (green)
         echo -en "\e]P3dfaf8f" # yellow        (brown)
         echo -en "\e]PBf0dfaf" # bright-yellow (yellow)
         echo -en "\e]P4506070" # blue          (darkblue)
         echo -en "\e]PC94bff3" # bright-blue   (blue)
         echo -en "\e]P5dc8cc3" # purple        (darkmagenta)
         echo -en "\e]PDec93d3" # bright-purple (magenta)
         echo -en "\e]P68cd0d3" # cyan          (darkcyan)
         echo -en "\e]PE93e0e3" # bright-cyan   (cyan)
         echo -en "\e]P7dcdccc" # white         (lightgrey)
         echo -en "\e]PFffffff" # bright-white  (white)
         ;;
esac

[[ -z "$TMUX" ]] && exec tmx gen-base

# Set the editor
export VLESS=$(find /usr/share/vim -name 'less.sh')
if [ ! -z $VLESS ]; then
    alias less=$VLESS
fi
# Source the aliases configuration
. ~/.aliases

setopt noautocd extendedglob
# bindkey -e
# The following lines were added by compinstall
zstyle :compinstall filename '/home/zach/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# SSH stuff
if [ -n "$SSH_CONNECTION" ]; then
    typeset -A POWERLINE_CONFIG
    POWERLINE_CONFIG=("common.dividers.left.soft" "<" "common.divders.left.hard" "" "common.dividers.right.soft" ">" "common.dividers.right.hard" "")    
fi

# Prompt fancification
if [ -e /usr/share/zsh/site-contrib/powerline.zsh ]; then
. /usr/share/zsh/site-contrib/powerline.zsh
export VIRTUAL_ENV_DISABLE_PROMPT="true"
else
    PS1="$fg[blue][\u@\h:$fg[yellow]\W$fg[blue]]$reset"
fi

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Intro message
echo -e "$fg[magenta]$(fortune -s | cowsay -s -W60)$reset_color"

