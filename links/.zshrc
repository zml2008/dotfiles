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

setopt noautocd extendedglob completealiases HIST_IGNORE_DUPS
# bindkey -e
# The following lines were added by compinstall
zstyle :compinstall filename '/home/zach/.zshrc'
zstyle ':completion:*' rehash true

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Dirstack via archwiki
DIRSTACKFILE="$HOME/.cache/zsh/dirs"
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
    dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
    [[ -d $dirstack[1] ]] && cd $dirstack[1]
fi
chpwd() {
  print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}

DIRSTACKSIZE=20

setopt autopushd pushdsilent pushdtohome

## Remove duplicate entries
setopt pushdignoredups

### This reverts the +/- operators.
setopt pushdminus

# Help command via archwiki
autoload -U run-help
autoload run-help-git
autoload run-help-svn
autoload run-help-svk
unalias run-help
alias help=run-help

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
    PS1="%*|$fg[blue][%n@%%m:$fg[yellow]%~$fg[blue]]>$reset_color"
fi

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Intro message
echo -e "$fg[magenta]$(fortune -s | cowsay -s -W60)$reset_color"

