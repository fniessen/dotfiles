## bash_profile --- Bourne Again Shell configuration file (for interactive shells)

# Copyright (C) 2003-2019 Fabrice Niessen

# Author: Fabrice Niessen <(concat "fniessen" at-sign "pirilampo.org")>
# Keywords: bash, dotfile, config

# Code:

# If running in terminal...
if test -t 1; then
    # ... start Zsh directly (when I open "Bash on Ubuntu on Windows" for example)
    echo "Zsh"
    exec zsh
fi

# If not running interactively, don't do anything.
# isInteractive=$(echo $- | grep i)
[[ "$-" != *i* ]] && return

# Source global definitions only if the session is interactive.
if [[ $(expr index "$-" i) -ne 0 ]] && [[ -f /etc/bashrc ]]; then
    . /etc/bashrc
fi

# Regular colors.
grn="\[$(tput setaf 2)\]"
yel="\[$(tput setaf 3)\]"

# Bold colors.
BLK="\[$(tput setaf 0; tput bold)\]"
RED="\[$(tput setaf 1; tput bold)\]"
GRN="\[$(tput setaf 2; tput bold)\]"

reset_color="\[$(tput sgr0)\]"

# PROMPT_COMMAND + PS1 --- Default interaction prompt

# To be called just before the prompt is printed.
leuven-before-prompt() {
    RET=$?

    # Set a color prompt (unless in Emacs).
    case $TERM in
        cygwin|xterm*|rxvt-unicode)
            # `M-x shell' under Cygwin Emacs.
            # `M-x term' under Cygwin Emacs.
            local color_prompt=yes
            ;;
        emacs)
            # `M-x shell' under EmacsW32.
            local color_prompt=no
            ;;
    esac

    # Colorful prompt, based on whether the previous command succeeded or not.
    if [[ $RET -eq 0 ]]; then
        HILIT_RET=$GRN
    else
        HILIT_RET=$RED
    fi

    # Replace the `$HOME' prefix by `~' in the current directory.
    if [[ "$HOME" = "${PWD:0:${#HOME}}" ]]; then
        myPWD="~${PWD:${#HOME}}"
    else
        myPWD=$PWD
    fi

    # How many characters of the path should be kept.
    local pwd_max_length=15

    if [[ ${#myPWD} -gt $pwd_max_length ]]; then
        local pwd_offset=$(( ${#myPWD} - pwd_max_length ))
        myPWD="...${myPWD:$pwd_offset:$pwd_max_length}"
    fi

    # Prompt character.
    if [[ $EUID -eq 0 ]]; then
        local PROMPTCHAR="#"
    else
        local PROMPTCHAR="$"
    fi

    if [[ "$color_prompt" = "yes" ]]; then
        PS1="$grn\u@\h$BLK:${reset_color}$yel$myPWD${HILIT_RET} $RET${reset_color}$PROMPTCHAR "
    else
        PS1="\u@\h:$myPWD $RET$PROMPTCHAR "
    fi
}

# Execute the content of the `PROMPT_COMMAND' just before displaying the `PS1'
# variable.
case "$TERM" in
    "dumb")
        # No fancy multi-line prompt for TRAMP (see `tramp-terminal-type').
        # Don't confuse it!
        PS1="> "
        ;;
    *)
        PROMPT_COMMAND=leuven-before-prompt
        ;;
esac

# PS4 --- Used by "set -x" to prefix tracing output

# Get line numbers when you run with `-x'.
PS4='+'$grn'[$0:$LINENO]+ '${reset_color}

# Automatically cd into a  directory without the `cd' in front of it.
shopt -s autocd

# Correct dir spellings.
shopt -s cdspell

# Make sure display get updated when terminal window get resized.
shopt -q -s checkwinsize

# Append rather than overwrite history.
shopt -s histappend

# Make multi-line commandsline in history.
shopt -q -s cmdhist

# Store 10000 commands in history buffer.
export HISTSIZE=10000

# Store 10000 commands in history FILE.
export HISTFILESIZE=10000

# Avoid recording common commands (like ls, top and clear).
export HISTIGNORE=”ls*:top:clear”

# Ignore duplicate commands and commands starting with space.
export HISTCONTROL=ignoreboth           # Prefix a command with a space to keep it out of the history.

complete -A helptopic help
complete -A hostname ssh telnet nmap ftp ping host traceroute nslookup

bind '"\eh": "\C-a\eb\ed\C-y\e#man \C-y\C-m\C-p\C-p\C-a\C-d\C-e"'

# Source common settings.
. "$HOME"/config-shell                      # Error displayed if not found.

# This is for the sake of Emacs.
# Local Variables:
# mode: sh
# sh-shell: bash
# End:
