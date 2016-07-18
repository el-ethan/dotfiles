
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

##########

# Editor

if [ -z "$SSH_CONNECTION" ]; then
    alias ec="emacsclient -c -n"
    export EDITOR="emacsclient -c"
    export ALTERNATE_EDITOR=""
else
    export EDITOR=$(type -P emacs || type -P nano)
fi

export VISUAL=$EDITOR

mycomputer=$(hostname)

HOMEPATH="/home/ethan/Dropbox/development/kivy_fork/kivy"

if [[ $MYCOMPUTER == "ethan-ThinkPad-X200" ]]; then
    export PYTHONPATH="$PYTHONPATH:$HOMEPATH:/home/ethan/Dropbox/development"
else
    export PYTHONPATH="$PYTHONPATH:/home/ethan/git"
fi

# Aliases
alias cdd='cd $HOME/Dropbox/development/'

# Command redefinitions
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
# From http://askubuntu.com/a/22043/396191
alias sudo='sudo '

## Ryan's options
IGNOREEOF=2
SHORTEN_LEN=32

set -b
shopt -sq cdspell checkjobs cmdhist dirspell extglob globstar histreedit histverify no_empty_cmd_completion

GIT_LAST_REPO=
PROMPT_COMMAND=prompt_command
function prompt_command {
    CURDIR="`pwd`"
    parse_git_branch
    shorten_dir
}

function shorten_dir {
    d="`echo $CURDIR | sed "s#^$HOME#~#"`"
    ds="$d"
    dd="`dirname "$d"`/"
    if (echo $ds | grep "^$dd") &>/dev/null; then
        dd="`echo $dd | sed 's#\([^~./-]\)[^./-]*\([/.-]\)#\1\2#g'`"
        ds="$dd`basename "$ds"`"
    fi
    SHORTDIR="$ds"
}

function parse_git_branch {
    GIT_STATUS_BRANCH=
    GIT_STATUS_STATE=
    GIT_STATUS_REMOTE=
    git rev-parse --git-dir &> /dev/null
    if [ $? -eq 0 ]; then
        branch=
        state=
        remote=

        if [ -d .git -a "$GIT_LAST_REPO" != "$CURDIR" ]; then
            GIT_LAST_REPO=$CURDIR
            git status -uno
        fi

        git_status="$(git status 2>/dev/null)"
        branch_pattern="^(# |)On branch ([^${IFS}]*)"
        detached_branch_pattern="Not currently on any branch"
        remote_pattern="Your branch is (.*) of"
        diverge_pattern="Your branch and (.*) have diverged"
        untracked_pattern="Untracked files:"
        new_pattern="new file: "
        not_staged_pattern="Changes not staged for commit"
        not_staged_count_pattern="modified: "

        # files not staged for commit
        if [[ ${git_status} =~ ${not_staged_pattern} ]]; then
            #echo echo "${git_status}" \| grep "${not_staged_count_pattern}" \| wc -l
            not_staged_count=`echo "${git_status}" | grep "${not_staged_count_pattern}" | wc -l`
            state="✔(${not_staged_count})"
        fi
        # add an else if or two here if you want to get more specific
        # show if we're ahead or behind HEAD
        if [[ ${git_status} =~ ${remote_pattern} ]]; then
            if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
                remote="${remote}↑"
            else
                remote="${remote}↓"
            fi
        fi
        # new files
        if [[ ${git_status} =~ ${new_pattern} ]]; then
            remote="${remote}+"
        fi
        # untracked files
        if [[ ${git_status} =~ ${untracked_pattern} ]]; then
            remote="${remote}✖"
        fi
        # diverged branch
        if [[ ${git_status} =~ ${diverge_pattern} ]]; then
            remote="${remote}↕"
        fi
        # branch name
        if [[ ${git_status} =~ ${branch_pattern} ]]; then
            branch=${BASH_REMATCH[2]}
        # detached branch
        elif [[ ${git_status} =~ ${detached_branch_pattern} ]]; then
            branch="NO BRANCH"
        fi

        GIT_STATUS_BRANCH=$branch
        GIT_STATUS_STATE=$state
        GIT_STATUS_REMOTE=$remote
    fi

    export GIT_STATUS_BRANCH
    export GIT_STATUS_STATE
    export GIT_STATUS_REMOTE
}




###### Ubuntu defaults ######

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac


# History settings

export HISTTIMEFORMAT='%b %d %I:%M %p '    # using strftime format
export HISTCONTROL=ignoreboth              # ignoredups:ignorespace
export HISTIGNORE="history:pwd:exit:ls:ls -la:ll"

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
    else
    color_prompt=
    fi
fi


if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]${SHORTDIR}\[\033[00m\]${GIT_STATUS_BRANCH:+\[\033[01;37m\] (\[\033[01;33m\]${GIT_STATUS_BRANCH}\[\033[01;37m\]:\[\033[01;32m\]${GIT_STATUS_STATE}\[\033[01;31m\]${GIT_STATUS_REMOTE}\[\033[01;37m\])\[\033[00m\]}\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w${GIT_STATUS_BRANCH:+ (${GIT_STATUS_BRANCH}:${GIT_STATUS_STATE}${GIT_STATUS_REMOTE})}\$ '
fi

# if [ "$color_prompt" = yes ]; then
#     PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# else
#     PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
# fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export PATH="/usr/lib/ccache:$PATH"
export USE_CCACHE=1
