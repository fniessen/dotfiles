## bash_profile --- Bourne Again Shell configuration file (for interactive shells)

# Copyright (C) 2003-2016 Fabrice Niessen

# Author: Fabrice Niessen <(concat "fniessen" at-sign "pirilampo.org")>
# Keywords: bash, dotfile, config

#* Code:

# If not running interactively, don't do anything.
[[ "$-" != *i* ]] && return

# Source global definitions only if the session is interactive.
if ([ $(expr index "$-" i) -ne 0 ] && [ -f /etc/bashrc ]); then
    . /etc/bashrc
fi

# History.
HISTFILE=$HOME/.bash_history            # If paranoiac, `/dev/null'.
HISTSIZE=1000
HISTFILESIZE=1000
HISTIGNORE="&:[bf]g:exit"
HISTCONTROL=ignoredups

#** Controlling the Prompt

# Regular colors.
green=$(tput setaf 2)
yellow=$(tput setaf 3)

# Bold colors.
BLACK=$(tput setaf 0; tput bold)
RED=$(tput setaf 1; tput bold)
GREEN=$(tput setaf 2; tput bold)

reset_color=$(tput sgr0)

#*** PROMPT_COMMAND + PS1 --- Default interaction prompt

# To be called just before the prompt is printed.
leuven-before-prompt ()
{
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
    if [ $RET -eq 0 ]; then
        HILIT_RET=${GREEN}
    else
        HILIT_RET=${RED}
    fi

    # Replace the `$HOME' prefix by `~' in the current directory.
    if [ "$HOME" = "${PWD:0:${#HOME}}" ]; then
        myPWD="~${PWD:${#HOME}}"
    else
        myPWD=$PWD
    fi

    # How many characters of the path should be kept.
    local pwd_max_length=15

    if [ ${#myPWD} -gt $pwd_max_length ]; then
        local pwd_offset=$(( ${#myPWD} - $pwd_max_length ))
        myPWD="...${myPWD:$pwd_offset:$pwd_max_length}"
    fi

    # Prompt character.
    if [[ $EUID -eq 0 ]]; then
        local PROMPTCHAR="#"
    else
        local PROMPTCHAR="$"
    fi

    if [ "$color_prompt" = "yes" ]; then
        PS1="${green}\u@\h${BLACK}:${yellow}${myPWD}${HILIT_RET} ${RET}${reset_color}${PROMPTCHAR} "
    else
        PS1="\u@\h:${myPWD} ${RET}${PROMPTCHAR} "
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

#*** PS2 --- Continuation interactive prompt

#*** PS3 --- Prompt used by "select" inside shell script

#*** PS4 --- Used by "set -x" to prefix tracing output

# Get line numbers when you run with `-x'.
PS4='+'${green}'[$0:${LINENO}]+ '${reset_color}

# Permissions on newly created files.
umask 022                               # Prevent new dirs and files from being
                                        # group and world writable.
if [[ $EUID -eq 0 ]]; then
    umask 077                           # Stricter.
fi

# Correct minor misspellings of cd pathnames.
shopt -s cdspell

#** 8.6 Programmable Completion

complete -A helptopic help
complete -A hostname ssh telnet nmap ftp ping host traceroute nslookup

# # Get a file's basename, dirname, extension, etc
#
# # Get extension; everything after last '.'.
# ext=${file##*.}
#
# # Basename.
# basename=`basename "$file"`
# # Everything after last '/'.
# basename=${file##*/}
#
# # Dirname.
# dirname=`dirname "$file"`
# # Everything before last '/'.
# basename=${file%/*}

# Source common settings.
: ${SHELLRC_LEUVEN:="$HOME/src/shellrc-leuven"} # Necessary to use $HOME!
. $SHELLRC_LEUVEN/etc/commonprofile

#* Local Variables

# This is for the sake of Emacs.
# Local Variables:
# mode: sh
# mode: outline-minor
# sh-shell: bash
# End:

## bash_profile ends here
