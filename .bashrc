# Generated with bashrc generator: https://alexbaranowski.github.io/bash-rc-generator/
# History Settings

export HISTFILESIZE=999999
export HISTSIZE=999999
export HISTTIMEFORMAT="%d-%m-%y:%T "

shopt -s histappend
export PROMPT_COMMAND="history -a; history -r; $PROMPT_COMMAND"

# Aliases
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
hash colordiff &> /dev/null && alias diff='colordiff'
# Extra options

export EDITOR="nano"

export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
