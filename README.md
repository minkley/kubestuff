# Quick start to building a Kubernetes cluster using Vagrant

If you are looking to learn kubernetes and possibly do the Certified Kubernetes Admin exam,
you might find this helpful.  It's stil very much a work in progress.

## Pre-Requisites
This files and code in this repository have only been tested on a linux ubuntu & Mac OS host.
You need to install the following software on your host.   Apologies to Windows users, I don't
have access to windows.

   git 
   vagrant
   Oracle virtualbox  
    
If you have never used these before, after you have completed your install, check that you can 
access the commands from the command line

```
    git --version

    vboxmanage --version

    vagrant version 
```
    
    Apologies to Windows users, I'm not sure how the command line works, dont have windows
    os to test 


1. Clone the repo
   git clone https://github.com/minkley/kubestuff.git


2. Go to the kubestuff directory
   cd kubestuff

3. Validate the Vagrantfile
   vagrant validate
   Vagrantfile validated successfully.

4. Build the cluster
   The vm names are control, worker01, worker02 & worker03.  You can build all at once or
   one at a time.  Vagrant will down load the vm images required for install.  I have chosen
   centos vms' and so the kubernetes setup are for Centos


   #Build everything 
   vagrant up

   #Build by name 
   vagrant up control
   or
   vagrant up control worker01
   ..

5. When the cluster is built log into each using vagrant
   
   vagrant ssh control
   or 
   vagrant ssh worker01

   password is vagrant btw


7  To setup your cluster you need to complete the following activities.

   initialiase kubernetes with kubeadm init command. Create the admin config directories and
   install network driver.  After this you can log in to each worker and join the cluster
   NOTE: kubeadm init command will print out join command with a token.  Suggest you copy this into
   a file 

   vagrant ssh control
   
   kubeadm init --pod-network-cidr 172.16.0.0/16 --apiserver-advertise-address 10.1.1.10 | tee /vagrant/kubeadm-init.out

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Next install a Network driver. I have selected Weave
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.1.221:6443 --token 4zhlk8.uq688xuump0t3u44 \
    --discovery-token-ca-cert-hash sha256:9e27b013402de2b5d08fc8fc6a251f9518034389648a76cb6cca5e26f5c988d2 


Output of the above commands

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.1.1.10:6443 --token 1dlpip.et4954ln8b7t7hsb \
    --discovery-token-ca-cert-hash sha256:f9a67e036e62d43d8b7ae35126f9938419c8d88a59ae79c80ad0449c0503a7fc
[vagrant@control ~]$   mkdir -p $HOME/.kube
[vagrant@control ~]$   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
[vagrant@control ~]$   sudo chown $(id -u):$(id -g) $HOME/.kube/config
[vagrant@control ~]$ kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
serviceaccount/weave-net created
clusterrole.rbac.authorization.k8s.io/weave-net created
clusterrolebinding.rbac.authorization.k8s.io/weave-net created
role.rbac.authorization.k8s.io/weave-net created
rolebinding.rbac.authorization.k8s.io/weave-net created
daemonset.apps/weave-net created
[vagrant@control ~]$ ssh vagrant@worker01
The authenticity of host 'worker01 (10.1.1.11)' can't be established.
ECDSA key fingerprint is SHA256:kOTPApXlRCw/n2JuZ4smDWVR2Q+9E4s9n9Uw130FcBY.
ECDSA key fingerprint is MD5:2e:4d:85:6a:09:2b:4d:de:59:63:ba:88:b6:08:4a:a6.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'worker01,10.1.1.11' (ECDSA) to the list of known hosts.
vagrant@worker01's password:
[vagrant@worker01 ~]$ sudo kubeadm join 10.1.1.10:6443 --token 1dlpip.et4954ln8b7t7hsb \
>     --discovery-token-ca-cert-hash sha256:f9a67e036e62d43d8b7ae35126f9938419c8d88a59ae79c80ad0449c0503a7fc
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

[vagrant@worker01 ~]$ exit
logout
Connection to worker01 closed.
[vagrant@control ~]$ kubectl get nodes
NAME       STATUS   ROLES    AGE     VERSION
control    Ready    master   4m30s   v1.19.3
worker01   Ready    <none>   81s     v1.19.3


vagrant@control ~]$ kubectl cluster-info
Kubernetes master is running at https://10.1.1.10:6443
KubeDNS is running at https://10.1.1.10:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.



[vagrant@control ~]$ kubectl get pods --all-namespaces
NAMESPACE     NAME                              READY   STATUS    RESTARTS   AGE
kube-system   coredns-f9fd979d6-2cxt4           1/1     Running   0          7m39s
kube-system   coredns-f9fd979d6-xxcr5           1/1     Running   0          7m39s
kube-system   etcd-control                      1/1     Running   0          7m49s
kube-system   kube-apiserver-control            1/1     Running   0          7m49s
kube-system   kube-controller-manager-control   1/1     Running   0          7m48s
kube-system   kube-proxy-4bd4m                  1/1     Running   0          7m39s
kube-system   kube-proxy-vvftg                  1/1     Running   0          4m49s
kube-system   kube-scheduler-control            1/1     Running   0          7m49s
kube-system   weave-net-4xr72                   2/2     Running   0          5m54s
kube-system   weave-net-j49t2                   2/2     Running   1          4m49s


