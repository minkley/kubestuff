# Quick start to building a Kubernetes cluster using Vagrant

If you are looking to learn kubernetes and possibly do the Certified Kubernetes Admin exam,
you might find this helpful.  It's stil very much a work in progress.

## Pre-Requisites
This files and code in this repository have only been tested on a linux ubuntu & Mac OS host.
You need to install the following software on your host.   Apologies to Windows users, I don't
have access to windows.


   git:  
          https://git-scm.com/downloads
   
   vagrant:  
         https://www.vagrantup.com/docs/installation
   
   Oracle virtualbox  
         https://www.virtualbox.org
    
If you have never used these before, after you have completed your install, check that you can 
access the commands from the command line

```
    git --version

    vboxmanage --version

    vagrant version 
```
    
    Apologies to Windows users, I'm not sure how the command line works, dont have windows
    os to test 


## Clone the repo
   `git clone https://github.com/minkley/kubestuff.git`

## Validate the Vagrantfile
`cd kubestuff # change to the kubestuff directory`

`vagrant validate # Validate the downloaded Vagrantfile`

*Vagrant file validated successfully.*


## Build the kubernetes VM's


   The vm names configured in the Vagrantfile are:
   - control
   - worker01
   - worker02
   - worker03  
  
  
  You can build all at once or one at a time.  The vm's are built using Centos and the first time you run vagrant, it will fetch the Centos image if it is not there.
  
  Build command is 

  `vagrant up <host, host> [default build everything.]`
   
   Build for the purpos of this excercise build control & worker01
   
   `vagrant up control worker01`

   Note - each vm will be automatically rebooted when vagrant is complete.  It takes about 5 minutes to build
   both on my machine.

## Logging on to control host 

   Each vm is created with user/password vagrant. 
   PLEASE DO NOT USE IN PRODUCTION.

   `vagrant ssh control`

   You can also run `ssh vagrant@controlIP `

   

## Complete the install on Control

Vagrantfile has installed Kubernetes and Container (docker) software and set IP address etc.  The following steps are outlined here.

- Intialise kubernetes with the `kubeadm init ` command.
- Create kuberenetes admin config directories in vagrant user home directory
- Install weave CNI (Container Network Interface) driver.
- Using the kubeadm init output, capture the `kubeadm join` output and run on workers

NOTE: kubeadmin init will save output in kubeadm-init.out file.  You can copy the join command and token 

```
   vagrant ssh control
   
   sudo kubeadm init --pod-network-cidr 172.16.0.0/16 --apiserver-advertise-address 10.1.1.10 | tee /vagrant/kubeadm-init.out
```

### Create the kube admin config directories

To start using your cluster, you need to run the following as a regular user:

~~~
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
~~~

### Install CNI driver

Next install a Network driver. I have selected Weave

`kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"`


### Sample output

```
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
```

## Joining the worker to the cluster

Look in the kubeadm-init.out file and paste the kubeadm join command.  This command needs to be run on each worker to join the cluster.  The join command contains the token needed to become member of the cluster

Then you can join any number of worker nodes by running the following on each as root:

Log on to worker01 from the control host

`ssh vagrant@worker01`

`sudo kubeadm join 10.1.1.10:6443 --token 1dlpip.et4954ln8b7t7hsb \
    --discovery-token-ca-cert-hash sha256:f9a67e036e62d43d8b7ae35126f9938419c8d88a59ae79c80ad0449c0503a7fc`

### Sample output
```
[vagrant@control ~]$ ssh vagrant@worker01
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
```

## Verification Checks 

After you have joined all the workers, you can run a few commands to check the status of the cluster.

- `kubectl get nodes`
- `kubectl cluster-info`
- `kubectl get pods --all-namespaces`


### Sample output
```
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


```

## Test your cluster.

There are some great application examples available on the kubernetes.io which you can
follow to test and kick the tyres on your cluster.

https://kubernetes.io/docs/tutorials/stateless-application/guestbook/

```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-deployment.yaml

kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-service.yaml

kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-deployment.yaml

kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-service.yaml

kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-deployment.yaml

kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-service.yaml

```

## Todo

- Everything could be packed into the single Vagrantfile
- Test on Windows
- Build Ubuntu vm's and other flavors
