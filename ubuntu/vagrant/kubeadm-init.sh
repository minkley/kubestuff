echo " setting up the kmaster"
echo $HOME:$USER

sudo kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=192.168.56.2 >/vagrant/kadmin.out 2>&1

export KADMIN_CMD=$(sudo egrep -A1 "kubeadm join" /vagrant/kadmin.out )
echo "sudo ${KADMIN_CMD}">/vagrant/ubuntu/vagrant/node_join_cluster.sh


echo "Check the vagrant directory on provisioning machine for the node_join_cluster.sh"


#To start using your cluster, you need to run the following as a regular user:
#
  runuser -l vagrant --command='mkdir -p $HOME/.kube'
  runuser -l vagrant --command='sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config'
  runuser -l vagrant --command='sudo chown $(id -u):$(id -g) $HOME/.kube/config'

# root can run kubectl
export KUBECONFIG=/etc/kubernetes/admin.conf

echo "Checking cluster info"
kubectl cluster-info

##
#Alternatively, if you are the root user, you can run:
#
#  export KUBECONFIG=/etc/kubernetes/admin.conf
#
#You should now deploy a pod network to the cluster.
#Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#  https://kubernetes.io/docs/concepts/cluster-administration/addons/
#
#Then you can join any number of worker nodes by running the following on each as root:
#
#kubeadm join 192.168.56.2:6443 --token mfo0xd.u15wrrb584o3vn3i \
#        --discovery-token-ca-cert-hash sha256:408c768db7fc647101e7d6d59f7607a2a87e887ed75cdf7b4ddfd610b5edd4e5

# Install command completion

echo " Adding kubectl completion "
kubectl completion bash >/etc/bash_completion.d/kubectl
