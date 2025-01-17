# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Add wisely, as too many plugins slow down shell startup.
plugins=(git)
plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf
source <(fzf --zsh)
alias f=fzf
# preview with bat
alias fp='fzf --preview="bat --color=always {}"'
# open neovim with select file by tab
alias fv='nvim $(fzf -m --preview="bat --color=always {}")'


# my alias for an easier life
alias v=nvim
alias vim=nvim
alias nv=nvim
alias ovim=vim
alias oc='cd ~/Documents/git && echo "Went to the git folder"'
alias ob='open -a Firefox\ Developer\ Edition'
alias os='nvim ~/.zshrc'
alias ss='source ~/.zshrc'
op() {
  local dir=~/Documents/git/"$1"
  if [ -d "$dir" ]; then
    cd "$dir" && echo "went to the ~/Document/git/$1 folder" || return 1
  else
    echo "Could not find the directory: $1"
    return 1
  fi
}
alias oh='cd ~/ && echo "Went back home"'
alias k='kubectl'
alias gr=./gradlew
# source tmux
alias stm='tmux source-file ~/.tmux.conf \;'
# confirm before remove something... fk.
alias rm="rm -i"
# PATH
export PATH="/opt/homebrew/share/android-commandlinetools/cmdline-tools/latest/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH=$JAVA_HOME/bin:$PATH
alias vcf="cd ~/.config/nvim && nvim"
alias python=python3
alias dc=docker-compose

# fetch then allow to fuzzy finding branches
alias gcof='git fetch && git checkout $(git branch | fzf | sed "s/^..//")'
