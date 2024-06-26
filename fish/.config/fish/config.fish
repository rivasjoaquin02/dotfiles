set fish_greeting ""
#fish_vi_key_bindings
set -gx TERM xterm-256color

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# ==================================
#             ALIASES
# ==================================
# for managing .dots with git bare 
alias ls "ls -p -G"
alias la "ls -A"
alias ll "ls -l"
alias lla "ll -A"

# exa: better ls
if type -q exa
    alias ls "exa --grid --color=auto --icons"
    alias la "exa -a --grid --color=auto --icons"
    alias ll "exa -l --icons --no-user --group-directories-first  --time-style long-iso -T -L2"
    alias lla "exa -la --icons --no-user --group-directories-first  --time-style long-iso -T -L2"
end

# git 
alias gi "git init"
alias gs "git status"
alias ga "git add"
alias gc "git commit"
alias gl "git log"
alias bc "better-commits"

alias v nvim
# ==================================
#             PATH
# ==================================
set -gx EDITOR nvim
set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH

# ==================================
#             AUTOSTART
# ==================================
if type -q starship
	starship init fish | source
end

# pnpm
set -gx PNPM_HOME "/home/strange/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
