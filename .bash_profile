export BASH_SILENCE_DEPRECATION_WARNING=1
export PATH="/opt/homebrew/bin:$PATH"
# export PATH="$HOME/.poetry/bin:$PATH"
# export PYENV_ROOT="$HOME/.pyenv"
# export PATH="$PYENV_ROOT/bin:$PATH"
# export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
# export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"
# export CFLAGS=-Wno-error=implicit-function-declaration
# export CPPFLAGS=-I/usr/local/opt/openssl/include

# export LDFLAGS="-L$(brew --prefix openssl)/lib" 
# export CFLAGS="-I$(brew --prefix openssl)/include"
# export PYTHON_KEYRING_BACKEND=keyring.backends.fail.Keyring

export VISUAL=code

export PATH="$HOME/.poetry/bin:$PATH"

export LDFLAGS="-L/opt/homebrew/opt/zlib/lib -L/opt/homebrew/opt/libheif/lib -L/opt/homebrew/opt/gettext/lib"
export CPPFLAGS="-I/opt/homebrew/opt/zlib/include -I/opt/homebrew/opt/libheif/include -I/opt/homebrew/opt/gettext/include"
export CONFIG=~/localdev/equipmentshare-api/test.local.ini

# poetry env use ~/.pyenv/versions/3.8.13/bin/python
# poetry shell
# export LDFLAGS="-L/opt/homebrew/opt/libheif/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/libheif/include"
# export CRYPTOGRAPHY_SUPPRESS_LINK_FLAGS=1 
# export LDFLAGS="$(brew --prefix openssl@1.1)/lib/libssl.a $(brew --prefix openssl@1.1)/lib/libcrypto.a" 
# export CFLAGS="-I$(brew --prefix openssl@1.1)/include"



alias pAuth='poetry config http-basic.codeartifact-dev aws $(aws codeartifact get-authorization-token --domain equipmentshare --domain-owner 696398453447 --query authorizationToken --output text) && aws codeartifact login --tool pip --repository dev --domain equipmentshare --domain-owner 696398453447'


DEV_HOME="~/localdev"

IGNOREEOF=42

alias ww='history | grep'
alias ddd='(cd ~/localdev/deja-vu-app/ && PORT=9000 npm run start:dev)'
alias edit_profile='code -n ~/.bash_profile'
alias stagedb='(cd ~/localdev/quickDb && yarn stage)'
alias proddb='(cd ~/localdev/quickDb && yarn prod)'
alias driveproddb='(cd ~/localdev/quickDb && yarn drive_prod)'
alias stagedbpw='(cd ~/localdev/quickDb && yarn stage_pw)'
alias proddbpw='(cd ~/localdev/quickDb && yarn prod_pw)'
alias driveproddbpw='(cd ~/localdev/quickDb && yarn drive_prod_pw)'


# Colorize terminal
alias ll='ls -alG'
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
export GREP_OPTIONS="--color"

# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
# export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
export HISTCONTROL=ignoreboth:erasedups

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

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
        branch_pattern="(^# |^)On branch ([^${IFS}]*)"
        detached_branch_pattern="Not currently on any branch"
        remote_pattern="Your branch is (.*) of"
        diverge_pattern="Your branch and (.*) have diverged"
        untracked_pattern="Untracked files:"
        new_pattern="new file: "
        not_staged_pattern="Changes not staged for commit"
        not_staged_count_pattern="modified: "
        # files not staged for commit
        if [[ ${git_status} =~ ${not_staged_pattern} ]]; then
            # echo echo "${git_status}" \| grep "${not_staged_count_pattern}" \| wc -l
            not_staged_count=`echo "${git_status}" | grep "${not_staged_count_pattern}" | wc -l | tr -d '[:space:]'`
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

export PS1='\[\033[01;32m\]ethan\[\033[00m\]:\[\033[01;34m\]${SHORTDIR}\[\033[00m\]\[\033[01;37m\] (\[\033[01;33m\]${GIT_STATUS_BRANCH}\[\033[01;37m\]:\[\033[01;32m\]${GIT_STATUS_STATE}\[\033[01;31m\]${GIT_STATUS_REMOTE}\[\033[01;37m\])\[\033[00m\]\$ '

unset color_prompt force_color_prompt

# Sensitive environment variables
source ~/.secrets

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

export ANDROID_HOME=/Users/ethan.skinner@equipmentshare.com/Library/Android/sdk
. "$HOME/.cargo/env"
 
#  Code artefact auth
#  pAuth
