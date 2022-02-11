export PATH="/Applications/Postgres.app/Contents/Versions/11/bin:$PATH"

# export PATH="\$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export BASH_SILENCE_DEPRECATION_WARNING=1

DEV_HOME="~/localdev"

IGNOREEOF=42

alias ww='history | grep'
alias run_migrations='bin/rake db:migrate RAILS_ENV=development';
alias staging-ls="git branch --list 'origin/master_pre_production_*' -a --sort=committerdate | tail -n 5 | sed -e 's/\(remotes\/origin\/\)//g'"
alias t="SPRING=1 rails test"
alias ddd='(cd ~/localdev/deja-vu-app/ && PORT=9000 npm run start:dev)'
alias todos='code -n /Users/ethan/Dropbox/deaddrop/backlot.taskpaper'
alias edit_profile='code -n ~/.bash_profile'
alias backlot='code /Users/ethan/Dropbox/deaddrop/backlot.md'

alias railz='bundle install && bin/rake db:migrate RAILS_ENV=development && rails s'

# Project aliases
alias archie="cd $DEV_HOME/archie && code ."
alias webapp="cd $DEV_HOME/webapp && code ."

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

export PS1='\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]${SHORTDIR}\[\033[00m\]\[\033[01;37m\] (\[\033[01;33m\]${GIT_STATUS_BRANCH}\[\033[01;37m\]:\[\033[01;32m\]${GIT_STATUS_STATE}\[\033[01;31m\]${GIT_STATUS_REMOTE}\[\033[01;37m\])\[\033[00m\]\$ '

unset color_prompt force_color_prompt

# Rollbar
#####################

# Sensitive environment variables
source ~/.secrets

# export PRE_QA_INSTANCE_IP="$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$PRE_QA_INSTANCE_NAME" --output text --query 'Reservations[*].Instances[*].NetworkInterfaces[*].Association.PublicIp')"

# echo -e "\nUsing database: \033[0;34m${DATABASE_NAME}\033[0m\n"

# sed -i '' "s#current \= .*#current \= $SQLALCHEMY_DATABASE_URI#" ~/.config/pgcli/config

export EDITOR="emacs"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

##### REDIS SERVER #####
function rediscom() {
  echo ''
  echo "'redstat' - checks the status of Redis; to see if it is running."
  echo "'redstart' - starts Redis"
  echo "'redstop' - stops Redis"
  echo "'redrestart' - stops Redis and then starts it again"
  echo "'rediscom' - shows the available aliases created for manipulating the Redis-CLI"
  echo ''
}


alias sshinit='ssh_init'
function ssh_init() {
  # For deploying webapp
  ssh-add ~/.ssh/id_rsa_blc_vpn
  ssh-add ~/.ssh/id_rsa
}


alias redstart='start_redis'
alias redstop='stop_redis'
alias redrestart='stop_redis && start_redis'
alias redstat='redis_status'

function start_redis() {
  # nohup redis-server /usr/local/etc/redis.conf > /dev/null 2>&1 &
  brew services start redis
}

function stop_redis() {
  # redis-cli shutdown
  brew services stop redis
}

function redis_status () {
  redis-cli time
  if [ $? = 0 ]; then
    echo "Redis is running."
  else
    echo "Redis is NOT running."
  fi
}

# redstat

### END REDIS STUFF ###

init-solr(){
  bundle exec rake sunspot:solr:stop RAILS_ENV=test
  bundle exec rake sunspot:solr:start
}

init-solr-test(){
  bundle exec rake sunspot:solr:stop
  bundle exec rake sunspot:solr:start RAILS_ENV=test
}
  
alias initsolr='init-solr'
alias initsolrtest='init-solr-test'

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
# Added by install_latest_perl_osx.pl
[ -r /Users/ethan/.bashrc ] && source /Users/ethan/.bashrc

[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

# echo `curl -s 'https://api.coindesk.com/v1/bpi/currentprice/btc.json' | jq -r '.bpi.USD.rate'`