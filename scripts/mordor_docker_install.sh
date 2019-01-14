#!/bin/bash

# Mordor script: mordor_docker_install.sh
# Mordor script description: Install docker
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Check if user is root ***************
if [[ $EUID -ne 0 ]]; then
   echo "[MORDOR-DOCKER-INSTALLATION-INFO] YOU MUST BE ROOT TO RUN THIS SCRIPT!!!" 
   exit 1
fi

# *********** Set Log File ***************
LOGFILE="/var/log/docker-install.log"
echoerror() {
    printf "${RC} * ERROR${EC}: $@\n" 1>&2;
}

# ********* Globals **********************
systemKernel="$(uname -s)"

# ********** Install Curl ********************
install_curl(){      
    echo "[MORDOR-DOCKER-INSTALLATION-INFO] Installing curl before installing docker.."
    case "$lsb_dist" in
        ubuntu|debian|raspbian)
            apt-get install -y curl >> $LOGFILE 2>&1
        ;;
        centos|rhel)
            yum install curl >> $LOGFILE 2>&1
        ;;
        *)
            echo "[MORDOR-DOCKER-INSTALLATION-INFO] Please install curl for $lsb_dist $dist_version.."
            exit 1
        ;;
    esac
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install curl for $lsb_dist $dist_version (Error Code: $ERROR)."
        exit 1
    fi
}

# ****** Installing docker via convenience script ***********
install_docker(){
    echo "[MORDOR-DOCKER-INSTALLATION-INFO] Installing docker via convenience script.."
    curl -fsSL https://get.docker.com -o get-docker.sh >> $LOGFILE 2>&1
    chmod +x get-docker.sh >> $LOGFILE 2>&1
    ./get-docker.sh >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
        echoerror "Could not install docker via convenience script (Error Code: $ERROR)."
        if [ -x "$(command -v snap)" ]; then
            SNAP_VERSION=$(snap version | grep -w 'snap' | awk '{print $2}')
            echo "[MORDOR-DOCKER-INSTALLATION-INFO] Snap v$SNAP_VERSION is available. Trying to install docker via snap.."
            snap install docker >> $LOGFILE 2>&1
            ERROR=$?
            if [ $ERROR -ne 0 ]; then
                echoerror "Could not install docker via snap (Error Code: $ERROR)."
                exit 1
            fi
            echo "[MORDOR-DOCKER-INSTALLATION-INFO] Docker successfully installed via snap."            
        else
            echo "[MORDOR-DOCKER-INSTALLATION-INFO] Docker could not be installed. Check /var/log/docker-install.log for details."
            exit 1
        fi
    fi
}

# *********** Main steps
if [ "$systemKernel" == "Linux" ]; then
    # *********** Check if curl is installed ***************
    if [ -x "$(command -v curl)" ]; then
        echo "[MORDOR-DOCKER-INSTALLATION-INFO] curl is already installed"
    else
        echo "[MORDOR-DOCKER-INSTALLATION-INFO] curl is not installed"
        install_curl
    fi

    # *********** Check if docker is installed ***************
    if [ -x "$(command -v docker)" ]; then
        echo "[MORDOR-DOCKER-INSTALLATION-INFO] Docker already installed"
    else
        echo "[MORDOR-DOCKER-INSTALLATION-INFO] Docker is not installed"
        install_docker
    fi
else
    # *********** Check if docker is installed ***************
    if [ -x "$(command -v docker)" ]; then
        echo "[MORDOR-DOCKER-INSTALLATION-INFO] Docker already installed"
    else
        echo "[MORDOR-DOCKER-INSTALLATION-INFO] Please innstall Docker for $systemKernel"
        exit 1
    fi
fi