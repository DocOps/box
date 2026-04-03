# DocOps Box — Zsh configuration for work images.
# This file is copied over the Oh My Zsh-generated .zshrc at image build time.
# Edit here to customize the shell for all DocOps Box work images.
# AsciiDoc include tags allow sections to be transcluded into documentation.

# tag::omz-init[]
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
# end::omz-init[]

# tag::git-prompt[]
ZSH_THEME_GIT_PROMPT_PREFIX=" (%{%F{cyan}%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{%f%})"
ZSH_THEME_GIT_PROMPT_DIRTY="%{%F{red}%}*%{%f%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
PROMPT='%n@$IMAGE_CONTEXT:%~$(git_prompt_info) %# '
# end::git-prompt[]

# tag::history[]
HISTFILE=/commandhistory/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS
# end::history[]

# tag::setopts[]
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS
# end::setopts[]

# tag::completion[]
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# end::completion[]

export EDITOR=${DEFAULT_EDITOR}
# tag::aliases[]
alias edit=nano
alias ls="ls -lha --color=auto"
alias cat="bat --paging=never"
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias jekyllserve="jekyll serve --host=0.0.0.0"
alias dxbx="echo 'Use the dxbx command from your HOST terminal; dxbx is invalid within the container.'"
# end::aliases[]

# tag::welcome[]
eval "$DOCOPS_WELCOME_COMMANDS"
# end::welcome[]
