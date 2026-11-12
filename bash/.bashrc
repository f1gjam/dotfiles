# Generated with bashrc generator: https://alexbaranowski.github.io/bash-rc-generator/
# History Settings

export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
export HISTFILESIZE=999999
export HISTSIZE=999999
export HISTTIMEFORMAT="%d-%m-%y:%T "

shopt -s histappend

export EDITOR="nano"


export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH
export PATH="/opt/homebrew/opt/uutils-coreutils/libexec/uubin:$PATH"
# uv/pipx-installed tools live here; after Homebrew and the system paths
export PATH="$PATH:/Users/kashif.ali/.local/bin"
export GOROOT="$(brew --prefix golang)/libexec"


#Need the below so you dont get ssl errors from aws cli
export AWS_CA_BUNDLE=$(brew --prefix)/etc/ca-certificates/cert.pem

eval "$(starship init bash)"


# Work stuff (Okta, Gemini/Google Cloud, work aliases) is sourced from
# ~/.config/secrets/work.env, which is kept outside this repo because it holds an API key.
[ -f "$HOME/.config/secrets/work.env" ] && . "$HOME/.config/secrets/work.env"
# BEGIN ANSIBLE MANAGED BLOCK: uutils aliases


# ==========================================
# MODERN LS DEFAULTS
# ==========================================

# Colour output automatically in interactive terminals
alias ls='ls --color=auto'

# Detailed listing, human-readable sizes
alias ll='ls -lah --color=auto'

# Almost all files, including hidden files
alias la='ls -A --color=auto'

# Directories first, with file-type indicators
alias lsd='ls -lah --group-directories-first --classify --color=auto'

# ==========================================
# USEFUL COREUTILS SHORTCUTS
# ==========================================

# Human-readable disk usage
alias du='du -h'

# Human-readable filesystem space
alias df='df -h'

# Better file size listing
alias dus='du -sh'

# Show directory sizes
alias dirsize='du -h -d 1'
# END ANSIBLE MANAGED BLOCK: uutils aliases
