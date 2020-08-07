# History
setopt HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Completion
autoload -Uz compinit
compinit
# Copied from Debian's /etc/zsh/newuser.zshrc.recommended
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Look for relevant package names when you run an unknown command. This is
# based on /etc/zsh_command_not_found but this version prints a message when it
# finds nothing.
if [[ -x /usr/lib/command-not-found ]] ; then
  function command_not_found_handler {
    [[ -x /usr/lib/command-not-found ]] || return 1
    /usr/lib/command-not-found -- ${1+"$1"} && :
  }
fi

# Vim mode
set -o vi
# This causes prompt_command() to be invoked whenever $KEYMAP changes.
zle-keymap-select () {
  zle reset-prompt
}
zle -N zle-keymap-select


# Set up prompt
parse_git_branch() {
  ref=$(git symbolic-ref HEAD -q 2>/dev/null)
  st=$?
  if [ $st -eq 1 ]; then
    echo "~~detached~~"
  elif [ $st -eq 0 ]; then
    echo "${ref#refs/heads/}"
  fi
}
prompt_command() {
  st=$?
  title=''
  visible='%B'

  # Print warning when previous command fails.
  if [ $status -ne 0 ]; then
    visible=$visible'%F{red}Command exited with status $st%f'$'\n'
  fi

  # Username and host
  if [ -n "$SSH_CLIENT" ] || [ -n "$SUDO_USER" ]; then
    visible=$visible'%F{yellow}%n@%m%f:'
    title=$title'%n@%m:'
  fi

  # Working directory
  visible=$visible'%F{green}%~%f'
  title=$title'%~'

  # Git branch
  git=$(parse_git_branch)
  if [ -n "$git" ]; then
    visible=$visible":%F{yellow}$git%f"
    title=$title":$git"
  fi

  # End prompt in '$' or '@' based on Vi mode
  if [ "$KEYMAP" = 'vicmd' ]; then
    visible=$visible'@'
  else
    visible=$visible'$'
  fi

  # End
  visible=$visible'%b '
  print -n "%{\e]2;$title\a%}$visible"
}
setopt PROMPT_SUBST
PROMPT='$(prompt_command)'