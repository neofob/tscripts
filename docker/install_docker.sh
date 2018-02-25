#!/usr/bin/env bash
# Just lines of bash codes from https://docs.docker.com/install/linux/docker-ce/ubuntu/
# Run this as ROOT
# ./install_docker.sh vagrant
# vagrant is the username to be added at the end of installtion

apt-get update
apt-get install -yq \
	apt-transport-https \
	ca-certificates \
	curl \
	software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

apt-key fingerprint 0EBFCD88

add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) \
	stable"

apt-get update
apt-get install -yq docker-ce

# groupadd docker
usermod -aG docker $1
