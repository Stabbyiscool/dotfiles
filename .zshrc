source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
PS1='%F{white}%n@%m%f
%F{white}%~%f\$ '
r() {
    close_after_run=0
    if [ "$1" = "-c" ]; then
        close_after_run=1
        shift
    fi
    nohup setsid "$@" >/dev/null 2>&1 </dev/null &
    if [ $close_after_run -eq 1 ]; then
        disown
        exit
    fi
}


HISTFILE=~/.zsh_history
alias mi="micro"
alias nano="micro"
alias roblox="flatpak run org.vinegarhq.Sober"
alias sober="flatpak run org.vinegarhq.Sober"

export XDG_CURRENT_DESKTOP=sway
export XDG_PORTAL_BACKEND=wlroots
export GTK_THEME=MonoThemeDark
