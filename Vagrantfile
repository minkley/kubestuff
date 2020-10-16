# -*- mode: ruby -*-
# vi: set ft=ruby :


ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'
### Centos is always a little finnicky
### This file is to setup 3 centos vms to go through 
### the Certified Kubernetes Admin training.
### I prefer ubuntu, but seems Centos 7 is the one being used in the training
### Notes:
### To install guest aditions run
### vagrant plugin install vagrant-vbguest
### Turn off all the firewall and disable SELinux
### sudo systemctl disable --now firewalld
### vi /etc/selinux/config ===> change SELINUX=disabled

$cka_docker = <<-'CKA'
  # script that runs 
  # https://kubernetes.io/docs/setup/production-environment/container-runtimes/
  
  sudo yum install -y vim yum-utils device-mapper-persistent-data lvm2
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

  # notice that only verified versions of Docker may be installed
  # verify the documentation to check if a more recent version is available

  sudo yum install -y docker-ce
  [ ! -d /etc/docker ] && sudo mkdir /etc/docker

  sudo cat > /etc/docker/daemon.json <<EOF
  {
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
      "max-size": "100m"
    },
    "storage-driver": "overlay2",
    "storage-opts": [
      "overlay2.override_kernel_check=true"
    ]
  }
EOF

  sudo mkdir -p /etc/systemd/system/docker.service.d

  sudo systemctl daemon-reload
  sudo systemctl restart docker
  sudo systemctl enable docker

CKA

$cka_kubetools = <<-'K8S'
# kubeadm installation instructions as on
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Set SELinux in permissive mode (effectively disabling it)
#setenforce 0
#sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# disable swap (assuming that the name is /dev/centos/swap
#sed -i 's/^\/dev\/mapper\/centos-swap/#\/dev\/mapper\/centos-swap/' /etc/fstab
#swapoff /dev/mapper/centos-swap

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet

# Set iptables bridging
sudo cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
#sudo echo "GATEWAY=192.168.1.1" >>/etc/sysconfig/network-scripts/ifcfg-eth1
K8S


$script = <<-'SCRIPT'
echo "running my commands" 
      sudo yum install -y net-tools
      sudo systemctl disable --now firewalld
      sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
      sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
      # Disable swap for kubernetes
      sudo sed -i '/swap/ s/^/#/' /etc/fstab 
      sudo yum install -y git bash-completion vim 
      sudo printf "10.1.1.10   control\n10.1.1.11   worker01\n10.1.1.12   worker02\n10.1.1.13   worker03\n" >> /etc/hosts
      #sudo echo "1" > /proc/sys/net/ipv4/ip_forward
      #sudo shutdown -r +1
SCRIPT
 
Vagrant.configure("2") do |config|
  ##### DEFINE Control #####
  config.vm.define "control" do |config|
    config.vm.provider "virtualbox" do |v|
      v.memory = 4096
      v.cpus = 2
    end
    config.vm.hostname = "control"
    config.vm.box = "centos/7"
    config.vm.box_version = "2004.01"
    config.vm.box_check_update = false
    #config.vm.network "public_network", bridge: 'wlp112s0',ip: "192.168.1.221"
    config.vm.network :private_network, ip: "10.1.1.10"
    ####
    #config.vm.provision "shell",
    #run: "always",
    #inline: "/sbin/route add default gw 192.168.1.1"

    # delete default gw on eth0
    #config.vm.provision "shell",
    #run: "always",
    #inline: "eval `/sbin/route -n | awk '{ if ($8 ==\"eth0\" && $2 != \"0.0.0.0\") print \"route del default gw \" $2; }'`"
    ####

    #config.ssh.forward_agent = true
    config.vm.provision "shell", inline: $script  
    config.vm.provision "shell", inline: $cka_docker
    config.vm.provision "shell", inline: $cka_kubetools
    config.vm.provision "shell", inline: "sudo shutdown -r +1"

  end



  ##### DEFINE worker01 #####
  config.vm.define "worker01" do |config|
    config.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 1
    end
    config.vm.hostname = "worker01"
    config.vm.box = "centos/7"
    config.vm.box_version = "2004.01"
    config.vm.box_check_update = false
    config.vm.network :private_network, ip: "10.1.1.11"

    #config.vm.network "public_network", bridge: 'wlp112s0', ip: "192.168.1.222"
    config.vm.provision "shell", inline: $script  
    config.vm.provision "shell", inline: $cka_docker
    config.vm.provision "shell", inline: $cka_kubetools
    config.vm.provision "shell", inline: "sudo shutdown -r +1"

    
  end

##### DEFINE worker02 #####
  config.vm.define "worker02" do |config|
    config.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 1
    end
    config.vm.hostname = "worker02"
    config.vm.box = "centos/7"
    config.vm.box_version = "2004.01"
    config.vm.box_check_update = false
    config.vm.network :private_network, ip: "10.1.1.12"
    #config.vm.network "public_network", bridge: 'wlp112s0',ip: "192.168.1.223"
    config.vm.provision "shell", inline: $script  
    config.vm.provision "shell", inline: $cka_docker
    config.vm.provision "shell", inline: $cka_kubetools
    config.vm.provision "shell", inline: "sudo shutdown -r +1"

  end

##### DEFINE worker02 #####
  config.vm.define "worker03" do |config|
    config.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 1
    end
    config.vm.hostname = "worker03"
    config.vm.box = "centos/7"
    config.vm.box_version = "2004.01"
    config.vm.box_check_update = false
    #config.vm.network "public_network", bridge: 'wlp112s0',ip: "192.168.1.224"
    config.vm.network :private_network, ip: "10.1.1.13"

    config.vm.provision "shell", inline: $script  
    config.vm.provision "shell", inline: $cka_docker
    config.vm.provision "shell", inline: $cka_kubetools
    config.vm.provision "shell", inline: "sudo shutdown -r +1"

  end
end



