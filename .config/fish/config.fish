if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting

alias v='nvim'

alias pipi='pip3 install'
alias pacup='sudo pacman -Syu'
alias pacs='sudo pacman -S'
alias pacr='sudo pacman -Rsn'
alias yayup='yay -Syu'

alias ls='exa --color=auto'
alias ll='ls -l'
alias la='ls -la'

alias f='ranger'

colorscript random
