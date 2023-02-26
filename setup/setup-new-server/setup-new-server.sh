#!/bin/bash

is_ubuntu=`awk -F '=' '/PRETTY_NAME/ { print $2 }' /etc/os-release | egrep Ubuntu -i`
is_centos=`awk -F '=' '/PRETTY_NAME/ { print $2 }' /etc/os-release | egrep CentOS -i`

echo "run with user root"
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

function ubuntu_basic_install()
{
	sudo apt -y update	
	sudo apt -y install git wget telnet rsync sysstat lsof nfs-common cifs-utils iptables chrony curl htop net-tools
	timedatectl set-timezone Asia/Ho_Chi_Minh
      ufw disable 
	systemctl start chronyd
	systemctl restart chronyd
	chronyc sources
	timedatectl set-local-rtc 0
}

function centos_basic_install()
{
  	yum update -y
  	yum install -y epel-release
  	yum groupinstall 'Development Tools' -y
	timedatectl set-timezone Asia/Ho_Chi_Minh 
	yum install -y git wget telnet rsync sysstat lsof nfs-utils cifs-utils iptables-services chrony curl htop net-tools 
	systemctl stop firewalld
	systemctl disable firewalld
	systemctl mask --now firewalld
	systemctl enable iptables
	systemctl start iptables
	systemctl enable chronyd
	systemctl restart chronyd
	chronyc sources
	timedatectl set-local-rtc 0
}

#Linux install basic tools
echo "Linux install basic tools"
if [ ! -z "$is_ubuntu" ]; then
	ubuntu_basic_install
elif [ ! -z "$is_centos" ]; then
	centos_basic_install
fi

echo "Enable limiting resources"
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
echo 'GRUB_CMDLINE_LINUX="cdgroup_enable=memory swapaccount=1"' | sudo tee -a /etc/default/grub
sudo update-grub

echo "Hostname: "
read hostname
hostnamectl set-hostname $hostname

#Create user isofh
function create_user()
{
    read adduser 
    if [ $adduser == 'y' ]; then
        echo "username: " 
        read user
        if [ $user == 'isofh' ]; then
            useradd -ms /bin/bash isofh
            #usermod -G wheel isofh
            passwd isofh
            echo "isofh ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
        elif [ $user != 'isofh' ]; then
            exit
        fi
    fi
}
echo "Do you want create user? [y/n]: "
create_user

#Create user monitor
echo "Create user monitor 'ucmea'"
useradd -ms /bin/bash ucmea
echo "ucmea:I!@#fh@123" | sudo chpasswd

echo "fs.file-max=100000
vm.swappiness=10" | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
echo "* soft nofile 100000" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 100000" | sudo tee -a /etc/security/limits.conf


echo "alias dils='docker image ls'
alias dirm='docker image rm'

alias dcls='docker container ls -a --size'
alias dcrm='docker container rm'

alias dcb='docker build . -t'

alias dr='docker restart'

alias dl='docker logs'

alias ds='docker stats'

alias din='docker inspect'

alias dcc='docker cp'

alias dload='docker load -i'

alias dlf='docker logs -f --tail 100'

function dcl() {
        sudo truncate -s 0 $(docker inspect --format='{{.LogPath}}' $1)
}

function drun() {
        docker run --rm $3 --name $2 -it $1 /bin/bash
}

function drun_network_host() {
        docker run --rm --network=host $3 --name $2 -it $1 /bin/bash
}

function dsave() {
        docker docker save -o $2 $1
}


function dexec() {
        container=$1

        docker exec -it $container /bin/bash
}

function dt() {
        for i in $( docker container ls --format "{{.Names}}" ); do
                echo Container: $i
                docker top $i -eo pid,ppid,cmd,uid
        done
}" | sudo tee -a /etc/bashrc


#Install docker
if [ ! -z "$is_ubuntu" ]; then
	is_docker_exist=`dpkg -l | grep docker -i`
elif [ ! -z "$is_centos" ]; then
	is_docker_exist=`rpm -qa | grep docker`
else
	echo "Error: Current Linux release version is not supported, please use either centos or ubuntu. "
	exit
fi

if [ ! -z "$is_docker_exist" ]; then
	echo "Warning: docker already exists. "
fi

function ubuntu_docker_install()
{
	#Install docker
	sudo apt-get -y update
	sudo apt-get remove docker docker-engine docker.io containerd runc 
	sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common  git vim 
	
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo \
		"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
		$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get -y update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose
	sudo bash -c 'touch /etc/docker/daemon.json' && sudo bash -c "echo -e \"{\n\t\\\"bip\\\": \\\"55.55.1.1/24\\\"\n}\" > /etc/docker/daemon.json"

	sudo systemctl enable docker.service
	sudo systemctl start docker
	usermod -aG docker isofh
		
#	is_docker_success=`sudo docker run hello-world | grep -i "Hello from Docker"`
#	if [ -z "$is_docker_success" ]; then
#		echo "Error: Docker installation Failed."
#		exit
#	fi
	
	echo "Docker has been installed successfully."
}

function centos_docker_install()
{
	#Install docker
	sudo yum install -y yum-utils device-mapper-persistent-data lvm2 git vim 
	sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	sudo yum -y install docker-ce docker-ce-cli containerd.io docker-compose
	sudo bash -c 'touch /etc/docker/daemon.json' && sudo bash -c "echo -e \"{\n\t\\\"bip\\\": \\\"55.55.1.1/24\\\"\n}\" > /etc/docker/daemon.json"

	sudo systemctl enable docker.service
	sudo systemctl start docker
	
	is_docker_success=`sudo docker run hello-world | grep -i "Hello from Docker"`
	if [ -z "$is_docker_success" ]; then
		echo "Error: Docker installation Failed."
		exit
	fi

	usermod -aG docker isofh

	echo "Docker has been installed successfully."		
}

function docker_compose_install()
{
	# Install docker-compose
	COMPOSE_VERSION=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oE "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1`
	sudo sh -c "curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
	sudo chmod +x /usr/local/bin/docker-compose
	sudo sh -c "curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"
	docker-compose --version
	echo "Docker-compose has been installed successfully."
}

function docker_install()
{
	if [ ! -z "$is_ubuntu" ]; then
		ubuntu_docker_install
	elif [ ! -z "$is_centos" ]; then
		centos_docker_install
	fi
}

function reboot_server()
{
	read -p "Please reboot for apply all config. [y/n]: " -n 1 -r
	echo    
	if [[ $REPLY =~ ^[Yy]$ ]]; then
	    /sbin/reboot
	fi
}

echo "Do you want install docker & docker compose? [y/n]: "
read docker
if [ $docker == 'y' ]; then
	docker_install
#	docker_compose_install
elif [ $docker != 'y' ]; then
	echo "Docker not installed"
fi
sudo docker run -d \
     --log-driver none \
     --name node-exporter \
     --net host \
     --pid host \
     --volume /proc:/host/proc \
     --volume /sys:/host/sys \
     --volume /:/rootfs \
     --volume /etc/node-exporter:/etc/node-exporter \
     prom/node-exporter \
         --path.procfs /host/proc \
         --path.sysfs /host/sys \
         --collector.filesystem.ignored-mount-points "^/(sys|proc|host|etc)($|/)"
		 
sudo docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=9092:8080 \
  --detach=true \
  --restart always \
  --name=cadvisor \
  --privileged \
  --device=/dev/kmsg \
  gcr.io/cadvisor/cadvisor:v0.37.5
reboot_server
