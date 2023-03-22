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
         . $(base16-template-for vconsole sh)
         ;;
esac

[ -e $HOME/.zshrc.local ] && . $HOME/.zshrc.local

[[ -z "$TMUX" ]] && [[ -n "$DISPLAY" ]] && exec tmx gen-base # Only open tmux automatically when we have a grahpcial session -- somehow tmux messes with startx :(

# Set the editor
export VLESS=$(find /usr/share/nvim -name 'less.sh')
if [ ! -z $VLESS ]; then
    alias less=$VLESS
fi

command -v thefuck > /dev/null && eval $(thefuck -a)
# Source the aliases configuration
. ~/.aliases

setopt noautocd extendedglob completealiases HIST_IGNORE_DUPS
# bindkey -e
# The following lines were added by compinstall
zstyle :compinstall filename '/home/zml/.zshrc'
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
export ZLE_RPROMPT_INDENT=0
# Prompt fancification
nvim -c "PromptlineSnapshot! ~/.zprompt.sh" -c ":q"
if [ -e $HOME/.zprompt.sh ]; then # Generation successful
    . $HOME/.zprompt.sh
else
    MAIN_COLOR=%{$fg_bold[blue]%}
    HL_COLOR=%{$fg[yellow]%}
    RESET=%{$reset_color%}
    PROMPT="%*|${MAIN_COLOR}[%n@%m:${HL_COLOR}%~${MAIN_COLOR}>${RESET}"
fi

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_STYLES[cursor]='underline,fg=magenta'

# Intro message
echo -e "$fg[magenta]$(fortune -s | cowsay -s -W60)$reset_color"

