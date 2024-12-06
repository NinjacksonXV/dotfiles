# Benchmark logic
# zmodload zsh/datetime
# setopt PROMPT_SUBST
# PS4='+$EPOCHREALTIME %N:%i> '
#
# logfile=$(mktemp zsh_profile.XXXXXXXX)
# echo "Logging to $logfile"
# exec 3>&2 2>$logfile
# setopt XTRACE
# End benchmark logic

# Official benchmark tool
# zmodload zsh/zprof

# Zinit can be installed with Nix, but since it's entirely shell-driven, we'll just install it to .local
# Install (if needed) and initialize zinit and its needed environment variables. 
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)" # If ZINIT_HOME folder isn't present, make it.
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" # If the git folderisn't present, clone the repo.  
source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# ZSH auto-completion parameters

source ~/.config/zsh/.zshrc-framework

HISTFILE=~/.config/zsh/.histfile
HISTSIZE=1000
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory 
setopt hist_ignore_space # prepend a space to prevent addition to history

stty -ctlecho # This disables the ^C echoing when killing an app

setopt autocd
unsetopt beep

# Keybindings
bindkey -e
bindkey '^H' backward-kill-word # Bind <C> + <BS> to delete word

bindkey ";5D" backward-word # Bind <C> + Left/Right to move 1 word
bindkey ";5C" forward-word

bindkey "^j" down-history # Bind <C> + j/k to scroll up/down through command history
bindkey "^k" up-history

bindkey '^p' history-search-backward 
bindkey '^n' history-search-forward 

zle -N run_neovide_hyprland
bindkey '^N' run_neovide_hyprland

zstyle ':completion:*' matcher-list 'm:{A-Za-z}={a-zA-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle :compinstall filename '/home/jacksonb/.zshrc' # I don't know what this does. It was put here automagically when I set up ZSH so I'll leave it be. 
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# https://gist.github.com/ctechols/ca1035271ad134841284#gistcomment-2308206
autoload -Uz compinit
compinit -C;

## Shell integrations and prompt ##
eval "$(zoxide init zsh --cmd cd)"
function cd() {
  if [ $# -gt 1 ]; then
    __zoxide_z "$@"
    return
  fi
  # redundant? 
  if [ -d "$1" ]; then
    __zoxide_z "$1"
    return
  fi

  local dir=$(find $(dirname $1) -maxdepth 1 -type d,l -wholename "*$(basename $1)*")
  if [ -d "$dir" ]; then
    __zoxide_z "./$dir"
  else
    __zoxide_z "$@"
  fi
}

eval "$(fzf --zsh)"
# https://thevaluable.dev/fzf-shell-integration/
alias shit='fuck'
alias godfuckin='fuck'
alias crap='fuck'
alias dammit='fuck'
alias goddamnit='fuck'
alias fuckinhell='fuck'
# Offloads evaluation (100ms) until the first invocation, at which point the new alias takes over. 
fuck(){
        eval $(thefuck --alias)
        fuck "$@"
}
eval "$(direnv hook zsh)"
if [ "$TERM" != "linux" ]; then
  eval "$(oh-my-posh init zsh)"
fi

# Aliases
alias ls='ls -A --color'
alias copy=$COPY_UTIL
alias cat='bat'
alias ff='fzf_with_preview'
alias reload='exec zsh'
alias reboot='systemctl shutdown -r now'
alias git-graph='git log --oneline --decorate --graph'
alias ags-restart='ags -q && ags &|'
# alias sudo='sudo ' # https://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias prolog='swipl'

alias nvid='run_neovide_hyprland'

# alias logout

# Nice idea, doesn't work on nix-os. Might be worth looking for a nix-specific solution that searches the store
xd()
{
  cd $(dirname $(whereis ${1} | awk '{ print $2 }'))
}

getip()
{
ip route get 1 | awk '{print $7;exit}'
}
 
## NEOVIM ##
  

run_neovide_hyprland_socket()
{
  neovide --fork
  nc -U "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" |  while read -r line; do
    if [[ ${line:0:10} == "openwindow" ]]; then
      echo "Neovide opened"
      break
    fi
  done
  kill $!
}

# Is this even necessary...?
run_neovide_hyprland()
{
  # Cover edgecase for --help crashing neovide
  for arg in "$@"; do
    if [[ "$arg" == "--help" ]]; then
      /usr/bin/env nvim --help
      return 0
    fi
  done
  run_neovide_de_agnostic $@ # Only way to set $!
  while ! hyprctl clients | grep $! >/dev/null; do done # Kill me
  hyprctl dispatch focuswindow pid:$! >/dev/null;
  return 0 # Previous command may fail, no need to set the error code

  # TODO: Substitute the following for `dispatch fullscreenstate` when Hyprland is updated to 0.43
  # hyprctl dispatch fullscreenstate 1
}

run_neovide_de_agnostic()
{
  neovide -- "$@" </dev/null >/dev/null 2>&1 &|
  # We redirect stdin to null so that the terminal doesn't hang when running exit.
    # TODO: It may be prudent to see if I can redirect STD out to the shell that launched it.
  # OR
  #  neovide --fork
  # This does not set $!, unlike the one above. 
}

# NeoVim Frontend SELector
nvfsel() {
  select frontend in Neovide Terminal
  do update_nvim_frontend_env_var $frontend; break;
  done;
  set_nvim_frontend_alias
}

set_nvim_frontend_alias()
{
  [[ $NVIM_FRONTEND = "term" ]] && unalias nvim &>/dev/null 
  [[ $NVIM_FRONTEND = "neovide" ]] && alias nvim='run_neovide_hyprland'
  return 0 # Nothing went wrong, I promise <3
}

update_nvim_frontend_env_var(){
  echo "$1 is now selected as default frontend."
  if [[ $1 = "Terminal" ]]; then
    sed -i "s/NVIM_FRONTEND=[^ ]*/NVIM_FRONTEND=term/" $ZDOTDIR/.zshenv
    echo "Note that Neovide can still be launched with the alias 'nvid'";
    NVIM_FRONTEND=term
  fi
  if [[ $1 = "Neovide" ]]; then 
    sed -i "s/NVIM_FRONTEND=[^ ]*/NVIM_FRONTEND=neovide/" $ZDOTDIR/.zshenv 
    NVIM_FRONTEND=neovide
  fi
}

nvsel() {
  select config in nvim nvchad 
  do update_nvim_config_env_var $config; break; 
  done;
}

update_nvim_config_env_var()
{
  echo "$1 is now selected as default config.";
  sed -i "s/NVIM_APPNAME=[^ ]*/NVIM_APPNAME=${1}/" $ZDOTDIR/.zshenv;
  source $ZDOTDIR/.zshenv;
}

fzf_with_preview()
{
  # For reference
  # https://vitormv.github.io/fzf-themes/
  # This works well, it just flashes in between fzf/bat. 
  # TODO
  #   Allow this to accept a list of items from STDIN (or as a parameter). 

# See the following to take in a list of items from STDIN
# if [ -t 0 ]; then
#     echo "No files provided"
#   else
#     mapfile -t files
#   fi
# for file in "${files[@]}"; do
#   done
  
  while true; do 
    if [[ ! -f ITEM ]]; then
      if [[ -f "${1}" ]]; then
        cd $(dirname $1)
        ITEM=$(basename "$1")
        ITEMS=$( ls *(.D) --color=none )
        ITEMS=$(echo "$ITEMS" | grep -v "$ITEM"; echo "$ITEM")

        echo $ITEMS
        return
      elif [[ -d "${1}" ]]; then
        cd $1
        ITEMS=$( ls *(.D) --color=none) 2>/dev/null
      else
        ITEMS=$(ls *(.D) --color=none ) 2>/dev/null
      fi
    else
      ITEMS=$(echo "$ITEMS" | grep -v "$ITEM"; echo "$ITEM")
    fi

    ITEM=$(echo $ITEMS | fzf --preview 'bat --color=always {}' --preview-window 'up,75%')

    if [[ -f $ITEM ]]; then
      bat "$ITEM" --paging=always 
    else
      break
    fi
  done
   
  return 0
}

if [ $TERM = "linux" ]; then
  NVIM_FRONTEND="term"
fi

set_nvim_frontend_alias

# zprof


# Begin end benchmark
