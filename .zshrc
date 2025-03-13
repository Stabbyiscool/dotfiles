source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
PS1='%F{white}%n@%m%f
%F{white}%~%f\$ '
r() {
    close_after_run=0
    use_fzf=0

    while getopts "cf" opt; do
        case $opt in
            c) close_after_run=1 ;;
            f) use_fzf=1 ;;
            *) echo "Usage: r [-c] [-f] command"; return 1 ;;
        esac
    done
    shift $((OPTIND-1))

    if [ $use_fzf -eq 1 ]; then
        app_id=$(flatpak list --app --columns=application | grep -i "$1" | head -n 1)

        if [ -n "$app_id" ]; then
            echo $app_id
            nohup flatpak run "$app_id" >/dev/null 2>&1 & 
            disown
        else
            echo "No matching app found, exiting."
        fi
    elif [ "$#" -gt 0 ]; then
        if command -v "$1" >/dev/null 2>&1; then
            nohup setsid "$@" >/dev/null 2>&1 </dev/null &
            disown
        else
            echo "Command '$1' not found."
        fi
    else
        echo "Usage: r [-c] [-f] command"
    fi

    if [ $close_after_run -eq 1 ]; then
        disown
        exit
    fi
}



HISTFILE=~/.zsh_history

export XDG_CURRENT_DESKTOP=sway
export XDG_PORTAL_BACKEND=wlroots
export GTK_THEME=MonoThemeDark
