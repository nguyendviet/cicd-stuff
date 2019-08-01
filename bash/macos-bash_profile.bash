# MAC OS .bash_profile file
# ============================== CUSTOM FUNCTIONS ==============================
# Git branch in prompt
parse_git_branch() {
   # space between dir name and (git branch)
   # git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
   # no space between dir name and (git branch)
   git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# export PS1="\u@\h:\W\[\033[0;35m\]\$(parse_git_branch)\[\033[00m\]$ "
# w = full path W = current dir
# more colours and style: 
export PS1="\[\033[0;32m\]\u@\h\[\033[00m\]:\[\033[0;33m\]\W\[\033[0;35m\]\$(parse_git_branch)\[\033[00m\]\$ "

# Copy folder to a server. You can choose withc file or folder to ignore
up_to_server() {
   rsync -rv "$1" --exclude={.git,.gitignore,.DS_Store,package-lock.json} username@servername_or_ip:./"$2"
}

# Download folder from a server
down_from_server() {
    rsync -rv username@servername_or_ip:./"$1" --exclude={node_modules} ./"$2"
}

# Combine 2 functions
sync_file_server() {
    if [ "$1" = "-u" ]; then
        rsync -rv "$2" --exclude={.git,.gitignore,.DS_Store,package-lock.json} username@servername_or_ip:./"$3"
    elif [ "$1" = "-d" ]; then
        rsync -rv username@servername_or_ip:./"$2" --exclude={node_modules} ./"$3"
    fi
}

# Remove all objects in an AWS S3 bucket
s3_remove() {
    aws s3 rm s3://"$1" --recursive
}

# Copy all files in a local folder to an AWS S3 bucket
s3_copy() {
    aws s3 cp "$1" s3://"$2" --recursive --exclude ".DS_Store"
}

# Create a CloudFormation stack from a json template.
# Depends on the template, it's required to have
# CAPABILITY_IAM, CAPABILITY_NAMED_IAM or CAPABILITY_AUTO_EXPAND
# If there is a 3rd arg, take the args from the 3rd one to the end as parameters
cloudformation_create() {
    if [ -z "$3" ]; then
        aws cloudformation create-stack --stack-name "$1" --template-body file://"$2" --capabilities CAPABILITY_IAM
    else
        aws cloudformation create-stack --stack-name "$1" --template-body file://"$2" --parameters "${@:3}" --capabilities CAPABILITY_IAM
    fi
}

# Specify each capabilities to avoid complex bash functions
cloudformation_create_named_iam() {
    if [ -z "$3" ]; then
        aws cloudformation create-stack --stack-name "$1" --template-body file://"$2" --capabilities CAPABILITY_NAMED_IAM
    else
        aws cloudformation create-stack --stack-name "$1" --template-body file://"$2" --parameters "${@:3}" --capabilities CAPABILITY_NAMED_IAM
    fi
}

cloudformation_create_auto_expand() {
    if [ -z "$3" ]; then
        aws cloudformation create-stack --stack-name "$1" --template-body file://"$2" --capabilities CAPABILITY_AUTO_EXPAND
    else
        aws cloudformation create-stack --stack-name "$1" --template-body file://"$2" --parameters "${@:3}" --capabilities CAPABILITY_AUTO_EXPAND
    fi
}

# Delete a cloudformation stack
cloudformation_delete() {
    aws cloudformation delete-stack --stack-name "$1"
}

# Describe Cognito UserPool and its Client
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

# ============================== ANSIBLE COMMANDS ==============================
alias vans="ssh viet@ansible.company.com"

# ============================== AWS COMMANDS ==============================
alias project1-update-prod="s3_remove project1.com && s3_copy ~/some-path/project1-repo-name/build project1.com"
alias project1-update-dev="s3_remove dev.project1.com && s3_copy ~/some-path/project1-repo-name/build dev.project1.com"

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

# ============================== FOLDER COMMANDS ==============================
# only for Linux Ubuntu
# alias opendir="xdg-open ."
alias cdmyproject="cd ~/lengthly-path/your-project-folder/"

# ============================== GIT COMMANDS ==============================
alias gs="git status"
alias gdh="git diff HEAD"
# see the changes you just staged
alias gds="git diff --staged"
# unstage file: git reset filename
alias greset="git reset"
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
alias gpushom="git push origin master"
alias gpull="git pull"
alias gpullom="git pull origin master"
alias gc="git clone"

alias grv="git remote -v"
alias grau="git remote add upstream"
alias gfu="git fetch upstream"

# get latest commit id
alias grph="git rev-parse HEAD"

# github and heroku
alias gphm="git push heroku master"

# ============================== GPG COMMANDS ==============================
alias gpgdec="gpg --passphrase-file ../path-to-file/passphrase.txt -d"

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

# ============================== REACT COMMANDS ==============================

# Create React app with npx
alias npxcra="npx create-react-app"

# ============================== TERRAFORM COMMANDS ==============================
alias tf="terraform"

# ============================== VIRTUAL ENVIRONMENT COMMANDS ==============================
# activate env + <env name>
alias startve="source activate"