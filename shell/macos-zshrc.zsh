# ============================== ENVIRONMENT VARIABLES ==============================

export NVM_DIR="$HOME/.nvm"
 [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
 [ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"  # This loads nvm bash_completion

# ============================== CUSTOM FUNCTIONS ==============================

# Git branch in prompt for zsh:
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    # git symbolic-ref --short HEAD 2> /dev/null
}

setopt PROMPT_SUBST
PS1='%{%F{green}%}%n@%m:%{%F{yellow}%}%1~%{%F{magenta}%}$(parse_git_branch)%{%F{none}%}$ '

# copy folder to Entarch
# should exclude node_modules folder but NDI entarch is to slow to install packages so it's faster just to upload it
up_to_entarch() {
  rsync -rv "$1" --exclude={.git,.gitignore,.DS_Store,package-lock.json} vnguyen@entarch.ndi.org:./"$2"
}

# download folder from Entarch
down_from_entarch() {
   rsync -rv vnguyen@entarch.ndi.org:./"$1" --exclude={node_modules} ./"$2"
}

sync_file_entarch() {
   if [ "$1" = "-u" ]; then
       rsync -rv "$2" --exclude={.git,.gitignore,.DS_Store,package-lock.json} vnguyen@entarch.ndi.org:./"$3"
   elif [ "$1" = "-d" ]; then
       rsync -rv vnguyen@entarch.ndi.org:./"$2" --exclude={node_modules} ./"$3"
   fi
}

# remove all objects in an AWS S3 bucket
s3_remove() {
    if [ "$2" ]; then
        aws s3 rm s3://"$1" --recursive --profile "$2"
    else
        aws s3 rm s3://"$1" --recursive
    fi
}

# copy all files in a local folder to an AWS S3 bucket
s3_copy() {
    if [ "$3" ]; then
        aws s3 cp "$1" s3://"$2" --recursive --exclude ".DS_Store" --profile "$3"
    else
        aws s3 cp "$1" s3://"$2" --recursive --exclude ".DS_Store"
    fi
}

# create a CloudFormation stack from a json template
# if CAPABILITY_NAMED_IAM required, pass in as 3rd arg named_iam
# if there is a 3rd/4th arg, take the args from the 3rd/4th one to the end as parameters
cloudformation_create() {
   if [ "$3" = "named_iam" ] && [ "$4" ]; then
       aws cloudformation create-stack --stack-name "$1" --template-body file://"$2" --parameters "${@:4}" --capabilities CAPABILITY_NAMED_IAM
   elif [ "$3" = "named_iam" ] && [ -z "$4" ]; then
       aws cloudformation create-stack --stack-name "$1" --template-body file://"$2" --capabilities CAPABILITY_NAMED_IAM
   elif [ "$3" != "named_iam" ] && [ "$3" ]; then
       aws cloudformation create-stack --stack-name "$1" --template-body file://"$2" --parameters "${@:3}" --capabilities CAPABILITY_IAM
   elif [ -z "$3" ]; then
       aws cloudformation create-stack --stack-name "$1" --template-body file://"$2" --capabilities CAPABILITY_IAM
   fi
}

# delete a cloudformation stack
cloudformation_delete() {
   aws cloudformation delete-stack --stack-name "$1"
}

# describe Cognito UserPool and its Client
cognito_describe_userpool() {
   if [ "$1" = "-c" ]; then
       aws cognito-idp describe-user-pool-client --user-pool-id "$2" --client-id "$3"
   else
       aws cognito-idp describe-user-pool --user-pool-id "$1"
   fi
}

# New line after cat command
my_cat() {
   cat "$1" ; echo
}
alias cat="my_cat"

# TEST A FUNCTION:
function test_func {
   local a="$1"
   local b="$2"

   if [ "$a" = "-u" ]; then
       echo "This means upload to $b"
   else
       echo "This means download to $b"
   fi
}

test_case() {
   echo "${@}"
   echo "$1"
   echo "$2"
   echo "${@:3}"
}

# Quick GitHub commit
git_out() {
   git status && git add . && git commit -m "$1" && git push && git status
}

# Go to repository and pull
cd_git_pull() {
    cd "$1" && git pull && git status\
    && printf "\n✅ Repository $2 is ready for work. 👍\n"
}

# ============================== AWS COMMANDS ==============================
alias mywebsite-update="s3_remove vietducnguyen.com && s3_copy ~/webdev/my-website/build vietducnguyen.com"
alias aws-viet="export AWS_DEFAULT_PROFILE=default"
alias veglist-update="s3_remove veglist.vietducnguyen.com && s3_copy ~/webdev/veglist/client/build veglist.vietducnguyen.com"

## AWS COMMANDS FOR NDI
alias aws-ndi="export AWS_DEFAULT_PROFILE=ndi"
alias cewa-update-prod="s3_remove nigeriavotescount.org && s3_copy build nigeriavotescount.org"
alias cewa-update-dev="s3_remove dev.nigeriavotescount.org && s3_copy build dev.nigeriavotescount.org"
alias asia-aed-build="cd ~/webdev/ndi/af-elections/ && export MB_TOKEN=pk.eyJ1IjoibmRpIiwiYSI6ImNqeW9lbDA1ajE0MDMzbG50Mm83OHZ1ZzAifQ.dSuLqIBGvOW8_EMbB-grsg && yarn build"
alias asia-aed-update-dev="s3_remove dev.afghanistanelectiondata.org ndi && s3_copy ~/webdev/ndi/af-elections/dist dev.afghanistanelectiondata.org ndi"

# ============================== CONDA COMMANDS ==============================
# create virtual env + <evn name> + <django or python version>
alias condacreate="conda create --name"

# show list of virtual environments
alias condalist="conda env list"

# remove specific env
alias condaremove="conda env remove --name"

# ============================== DJANGO COMMANDS ==============================
# create django project + <project name>
alias create-djpj="django-admin startproject"

# go to django admin templates folder
alias cd-django-admin-templates="cd /usr/local/lib/python3.6/dist-packages/django/contrib/admin/templates/admin"

# ============================== ENTARCH COMMANDS ==============================
alias vent="ssh vnguyen@entarch.ndi.org"

# ============================== FOLDER COMMANDS ==============================
# For Linux Ubuntu
# alias opendir="xdg-open ."
alias update-my-website="rm_obj_s3 vietducnguyen.com && up_s3 build vietducnguyen.com"
alias cdrpggame="cd ~/webdev/rpg-game"
alias cdwebdev="cd ~/webdev"
alias cdndi="cd ~/webdev/ndi"
alias cdcicd="cd_git_pull ~/webdev/cicd-stuff cicd-stuff"
alias cdveglist="cd_git_pull ~/webdev/veglist veglist"
alias cdalgo="cd_git_pull ~/webdev/algorithms algorithms"
alias cdvietgo="cd_git_pull ~/go/src/github.com/nguyendviet/vietgo vietgo"
alias cdmywebsite="cd_git_pull ~/webdev/my-website my-website"

# NDI repositories
alias cdconcur="cd_git_pull ~/webdev/ndi/ac-concur-costpoint ac-concur-costpoint"

# ============================== GO LANG ==============================
export PATH=$PATH:/usr/local/go/bin
# Add GOPATH to control installed Go libraries
# From: https://youtu.be/YS4e4q9oBaU
# export GOPATH=/Users/viet/go
# export PATH=$PATH:$GOPATH/bin
# export GOPATH=$GOPATH/Users/viet/code

# ============================== GIT COMMANDS ==============================
alias gs="git status"
alias gdh="git diff HEAD"
# see the changes you just staged
alias gds="git diff --staged"
# unstage file: git reset filename
alias grs="git reset"
# remove file: git rm filename or same type: git rm '*.txt'
alias grm="git rm"
# get rid off all changes from last commit: git checkout -- filename
alias gco-="git checkout --"

# save changed files before pull
alias gstash="git stash"
# restore saved files after pull
alias gsp="git stasch pop"

# see all branches: git branch
alias gb="git branch"
# switch to branch: git checkout branchName
alias gco="git checkout"
# switch back to branch Master
alias gcom="git checkout master"
# merge another branch whilst on branch master: git merge branchName
alias gm="git merge"
# delete branch: git branch -d branchName
alias gbd="git branch -d"

alias ga="git add"
alias gaa="git add -A"
# stage only currently tracked files, exlude untracked files: git add -u
alias gau="git add -u"
alias gcm="git commit -m"
alias gpush="git push"
alias gpull="git pull"
alias gpullom="git pull origin master"
alias gc="git clone"

# Custom-made git commands:
alias gitout="git_out"

# ============================== MYSQL COMMANDS ==============================
alias sqlrun="mysql -u root -p"

# ============================== NODEJS COMMANDS ==============================
# use node to run server.js by default
alias nrun="node server.js"
alias nmrun="nodemon server.js"

#https://docs.npmjs.com/cli/install
# install local package (by default add to package.json)
alias npmis="npm install --save"

# install local package to dev dependencies
alias npmisd="npm install --save-dev"

# install global package
alias npmig="npm install -g"

# uninstall and delete local package (by default remove from package.json)
alias npmus="npm uninstall --save"

# uninstall and remove package from package.json
alias npmud="npm uninstall --save-dev"

# uninstall global package
alias npmug="npm uninstall -g"

# ============================== NODEMON COMMANDS ==============================
# for more details: http://vwebdev.blogspot.com/2017/12/use-nodemon-with-babel.html
# install nomdemon babel locally
alias nodemon-babel-install="npm install --save-dev babel-cli babel-preset-env babel-preset-stage-2"

# run nodemon with babel
alias nmbrun="nodemon --exec babel-node --presets env,stage-2"

# ============================== PYTHON COMMANDS ==============================
# create app inside django project + <app name>
alias pyapp="python3 manage.py startapp"

# create migrations for model changes
alias pymakemig="python3 manage.py makemigrations"

# apply model changes to the database
alias pymig="python3 manage.py migrate"

# open shell
alias pyshell="python3 manage.py shell"

# create user + <super user name>
alias pyuser="python3 manage.py createsuperuser"

# run server
alias pyrun="python3 manage.py runserver"

# run test <app-name>
alias pytest="python3 manage.py test"

# build package (need setup.py file. more details: https://docs.djangoproject.com/en/2.0/intro/reusable-apps/#packaging-your-app)
alias pybuild="python3 setup.py sdist"

# ============================== VIRTUAL ENVIRONMENT COMMANDS ==============================
# activate env + <env name>
alias startve="source activate"

# deactivate env
alias exitve="source deactivate"
# Setting PATH for Python 3.7
# The original version is saved in .bash_profile.pysave
# PATH="/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"
# export PATH
