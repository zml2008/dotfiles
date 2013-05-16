#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
eval $(keychain --eval --agents ssh -Q --quiet id_rsa)
export EDITOR="/usr/bin/vim"
shopt -s checkwinsize
. ~/.aliases # Aliases file
export VLESS=$(find /usr/share/vim -name 'less.sh')
if [ ! -z $VLESS ]; then
  alias less=$VLESS
fi

C_PRIMARY='\[\e[32m\]'
C_PWD='\[\e[1;33m\]'
C_RESET='\e[0m'
C_PROMPT_RESET="\[${C_RESET}\]"
C_FORTUNE="\e[35m"

echo -e "${C_FORTUNE}$(fortune -s | cowsay -s -W60)$C_RESET"
. $(python -c 'import site; print(site.getsitepackages()[0])')/powerline/bindings/bash/powerline.sh
#PS1="${C_PRIMARY}[\u@\h:${C_PWD}\W${C_PRIMARY}]${C_PROMPT_RESET}» "
