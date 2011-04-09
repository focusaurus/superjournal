#!/bin/bash
#This is a wrapper script with shared install/deploy/run tasks.
#The code in here is shareable by many projects

#This script will source a project_tasks.sh script which will be
#project specific

#This script contains many install/deploy/run related tasks
#The tasks are defined as shell functions and prefixed with a namespace
#which is one of os, user, db, web, app, scm, test, etc.
#The goal is that once you figure out how to clone the git repository,
#You can use this script to get a dev, staging, or production environment
#up and running.  The script doesn't do 100% automation yet but it does a lot.
#You run it like this:
#tasks.sh staging app:start
#where "staging" is the environment name (defined below) and app:start is the
#task name.
#The script can be run locally in which case the task's shell function is just
#directly executed, or against one or more remote hosts, in which case
#this script handles copying itself to the remote hosts then running itself
#on each host.

TASK_SCRIPT="${0}"
TASK_DIR=$(dirname "${0}")

########## Shared Default Config Variables ##########
BRANCH=master

########## Shared helper functions ##########
cdpd() {
    cd "${PROJECT_DIR}"
}

########## No-Op Test Tasks for sudo, root, and normal user ##########
#Use these to make sure your passwordless ssh is working, hosts are correct, etc
test:uptime() {
    uptime
}

test:uptime_sudo() { #TASK: sudo
    uptime
    id
}
########## OS Section ##########
#Wrapper function for getting everything in the OS bootstrapped
os:initial_setup() { #TASK: sudo
    os:prereqs
}


#Install some Ubuntu packages using apt-get install
#We take a big string that can be multiline with comments
apt_install() { #TASK: sudo
    if ! which apt-get >/dev/null; then
        echo "apt-get not found in PATH.  Is this really an Ubuntu box?" \
            " Is your PATH correct?" 1>&2
        exit 5
    fi
    apt-get update
    echo "${1}" | grep -v "#" | sort | xargs apt-get --assume-yes install
}

#Helper function for symlinking files in the git work area out into the OS
link() {
    if [ ! -h "${1}" ]; then
        ln -s "${OVERLAY}${1}" "${1}"
    fi
}

########## User Section ##########
#Wrapper function
user:initial_setup() {
    user:ssh_config
}

#The ForwardAgent configuration allows proxied ssh agent authentication
#So the remote scripts can run git+ssh commands on the app server
#and the end user's authentication will be proxied from the end user's
#desktop to the app server through to the git SCM host
user:ssh_config() {
    KEYS=~/.ssh/authorized_keys
    [ -d ~/.ssh ] || mkdir ~/.ssh
    touch "${KEYS}"
    #This is plyons's public SSH key
    if ! grep "^ssh-rsa AAAAB3NzaC1yc2EAAAABI" "${KEYS}" > /dev/null 2>&1; then
        cat <<EOF | tr -d '\n' >> "${KEYS}"
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEArdBAo5yfb43w5/N3nxQvpDH6tCIvwvsJu/FrvRFiM8
+s/lGP0XxihzHYOJH/IdEz+WnjnKMBCWT/we3ZbWMFQ32yMzXAj2B+noaranIOLJ7C52uZrWoS2OOO
qWtwuj4jZLZ9v7cLvxC9v69b8dqyBOJG3YlIzqFQeYT7p4I1XWDRfwhsuX738zhvBYSx4w3tkZDmEp
sSl0+xNVjugBjNP81ynP3nUkeH+Ap2IUrJK5RnGpLXg+EX1DpPypXvn67SpHvz0+DgQuKwL+AYQdFS
86p21tuSDJ0yKz8CX+5nrJjjt2NUYgs0SwGU387UzqGFH5711C2rc9gkD6cvGbX0mQ
== zoot MacBook pro
EOF
    #Need a trailing newline
    echo >> "${KEYS}"
    fi
    touch ~/.ssh/config
    if ! grep "^Host git.peterlyons.com" ~/.ssh/config > /dev/null 2>&1; then
        cat <<EOF>> ~/.ssh/config
Host git.peterlyons.com
  ForwardAgent yes
EOF
    fi
}

########## git SCM section ##########
scm:deploy() {
    cdpd
    echo "Deploying branch ${1-${BRANCH}}"
    git fetch origin --tags
    git checkout --track -b "${1-${BRANCH}}" || git checkout "${1-${BRANCH}}"
    git pull origin "${1-${BRANCH}}"
}

scm:clone() {
    PARENT="$(dirname ${PROJECT_DIR})"
    [ -d "${PARENT}" ] || mkdir -p "${PARENT}"
    cd "${PARENT}"
    git clone "${REPO_URL}"
    cd "${PROJECT_DIR}"
    git checkout "${BRANCH}"
    cd
}


scm:prod_release() {
    echo "Performing a production release"
    eval $(ssh-agent -s) && ssh-add
    git checkout develop
    git pull origin develop
    echo "Current version is $(cat version.txt)"
    echo -n "New version: "
    read NEW_VERSION
    git checkout -b "release-${NEW_VERSION}" develop
    echo "${NEW_VERSION}" > version.txt
    git commit -a -m "Bumped version number to ${NEW_VERSION}"
    echo "ABOUT TO MERGE INTO MASTER. CTRL-C now to abort. ENTER to proceed."
    read DONTCARE
    git checkout master
    git merge --no-ff "release-${NEW_VERSION}"
    echo "Now type notes for the new tag"
    git tag -a "v${NEW_VERSION}"
    git checkout develop
    git merge --no-ff "release-${NEW_VERSION}"
    git branch -d "release-${NEW_VERSION}"
    git push origin develop
    git checkout master
    git push origin master
    git checkout develop #Not good form to leave master checked out
    echo "Ready to go. Type './bin/tasks.sh production app:deploy' to push to production"
}

########## Web (nginx) Section ##########
_web() {
    sudo /etc/init.d/nginx "${1}"
}

web:restart() {
     _web restart
}

web:reload() {
     _web reload
}

web:stop() {
    _web stop
}

web:start() {
    _web start
}

if ! expr "${1}" : '.*:' > /dev/null; then
    ENV_NAME="${1}"
    shift
    OP="${1}"
    shift
    case "${ENV_NAME}" in
        staging)
            HOSTS="${STAGING_HOSTS}"
        ;;

        production)
            HOSTS="${PRODUCTION_HOSTS}"
        ;;
    esac
else
    OP="${1}"
    shift
fi

case "${OP}" in
    app:*|db:*|os:*|scm:*|test:*|user:*|web:*)
        #Op looks valid-ish
    ;;
    *)
        echo "ERROR: unknown task ${OP}" 1>&2
        exit 1
    ;;
esac

#figure out sudo
for FILE in "${TASK_SCRIPT}" "${TASK_DIR}"/*_tasks.sh
do
    if egrep "^${OP}\(\).*#TASK: sudo" "${FILE}" > /dev/null; then
        SUDO=sudo
    fi
done

if [ -z "${ENV_NAME}" ]; then
    #local mode
    #Now load in the project-specific stuff
    for FILE in "${TASK_DIR}/"*_tasks.sh
    do
        echo "BUGBUG loading ${FILE}"
        source "${FILE}"
    done
    setup
    eval "${OP}" "${@}"
else
    #remote mode
    for HOST in ${HOSTS}
    do
        echo "Running task ${OP} as ${SUDO-$USER}@${HOST}"
        scp "${TASK_SCRIPT}" "${TASK_DIR}/"*_tasks.sh "${HOST}:/tmp"
        ssh -q -t "${HOST}" "${SUDO}" bash  \
            "/tmp/$(basename ${TASK_SCRIPT})" "${OP}" "${@}"
    done
fi
