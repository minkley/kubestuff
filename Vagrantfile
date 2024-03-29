# -*- mode: ruby -*-
# vi:set ft=ruby sw=2 ts=2 sts=2:

# Define the number of master and worker nodes
# If this number is changed, remember to update setup-hosts.sh script with the new hosts IP details in /etc/hosts of each VM.
NUM_MASTER_NODE = 1
NUM_WORKER_NODE = 2

IP_NW = "192.168.56."
MASTER_IP_START = 1
NODE_IP_START = 2

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # config.vm.box = "base"
  # ubuntu 18.04
  config.vm.box = "ubuntu/bionic64"
  #ubuntu 20.04
  # config.vm.box = ubuntu/focal64

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  # config.vm.synced_folder "/d/mdata2" , "/d/mdata2"
  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Provision Master Nodes
  (1..NUM_MASTER_NODE).each do |i|
      config.vm.define "kmaster" do |node|
        # Name shown in the GUI
        node.vm.provider "virtualbox" do |vb|
            vb.name = "kmaster"
            vb.memory = 4096
            vb.cpus = 2
        end
        node.vm.hostname = "kmaster"
        node.vm.network :private_network, ip: IP_NW + "#{MASTER_IP_START + i}"
        node.vm.network "forwarded_port", guest: 22, host: "#{2710 + i}"

        node.vm.provision "setup-hosts", :type => "shell", :path => "ubuntu/vagrant/setup-hosts.sh" do |s|
          s.args = ["enp0s8"]
        end


        node.vm.provision "setup-dns", type: "shell", :path => "ubuntu/vagrant/update-dns.sh"
        # Setup br-netfilter before docker adn kubernetes
        node.vm.provision "install-br-netfilter", type: "shell", :path => "ubuntu/vagrant/install-br_netfilter.sh"

        node.vm.provision "install-docker", type: "shell", :path => "ubuntu/vagrant/install-docker.sh"
        node.vm.provision "install-kubernetes", type: "shell", :path => "ubuntu/vagrant/install-kubernetes.sh"

        node.vm.provision "kubeadm-init",type: "shell", :path => "ubuntu/vagrant/kubeadm-init.sh"

        #node.vm.provision "pod-network-init",type: "shell", :path => "ubuntu/vagrant/install-CNI-Weave.sh"
        node.vm.provision "pod-network-init",type: "shell", :path => "ubuntu/vagrant/install-CNI-Calico.sh"




      end
  end



  # Provision Worker Nodes
  (1..NUM_WORKER_NODE).each do |i|
    config.vm.define "knode0#{i}" do |node|
        node.vm.provider "virtualbox" do |vb|
            vb.name = "knode0#{i}"
            vb.memory = 4096
            vb.cpus = 2
        end
        node.vm.hostname = "knode0#{i}"
        node.vm.network :private_network, ip: IP_NW + "#{NODE_IP_START + i}"
                node.vm.network "forwarded_port", guest: 22, host: "#{2720 + i}"

        node.vm.provision "setup-hosts", :type => "shell", :path => "ubuntu/vagrant/setup-hosts.sh" do |s|
          s.args = ["enp0s8"]
        end

        node.vm.provision "setup-dns", type: "shell", :path => "ubuntu/vagrant/update-dns.sh"
# Setup br-netfilter first before docker & kubernetes
        node.vm.provision "install-br-netfilter", type: "shell", :path => "ubuntu/vagrant/install-br_netfilter.sh"

        node.vm.provision "install-docker", type: "shell", :path => "ubuntu/vagrant/install-docker.sh"
        node.vm.provision "install-kubernetes", type: "shell", :path => "ubuntu/vagrant/install-kubernetes.sh"
        # If next line fails, its because kubeadm failed in control master provision.
        node.vm.provision "join-cluster", type: "shell", :path => "ubuntu/vagrant/node_join_cluster.sh"

    end
  end
end
