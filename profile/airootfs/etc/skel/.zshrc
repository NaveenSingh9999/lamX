# lamX shell - zsh with zinit, autosuggest, highlighting, pure prompt
setopt AUTO_CD nonomatch
autoload -Uz edit-command-line zmv
zle -N edit-command-line
bindkey '^X^E' edit-command-line
bindkey '^Z' undo
bindkey '^Y' redo
bindkey ' ' magic-space

if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  mkdir -p "$HOME/.local/share/zinit" && chmod g-rwX "$HOME/.local/share/zinit"
  git clone --depth 1 https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zi for is-snippet OMZL::{compfix,completion,git,key-bindings}.zsh PZT::modules/history
zi light-mode for zdharma-continuum/zinit-annex-{binary-symlink,patch-dl,submods}
zi ice zsh-users/zsh-completions
zi ice atload'_zsh_autosuggest_start' \
  atinit'ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50
bindkey "^_" autosuggest-execute
bindkey "^ " autosuggest-accept'
zi light zsh-users/zsh-autosuggestions
zi light-mode for zdharma-continuum/fast-syntax-highlighting
zi ice joshskidmore/zsh-fzf-history-search
zi ice atload'bindkey "^I" menu-select'
zi light marlonrichert/zsh-autocomplete

# pure prompt, async git, minimal two lines
zinit ice pick"async.zsh" src"pure.zsh"
zinit light sindresorhus/pure

alias ll='ls -lah'
export EDITOR=nvim
export TERMINAL=foot
[ ! -f "$HOME/.config/.setup-done" ] && echo "Run 'sudo lamx-setup' for first-time setup. 'lamx-help' for commands."
