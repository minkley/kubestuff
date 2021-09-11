# Introduction.

The Vagrantfile and scripts will build a Kubernetes cluster with a single Control Plane
and 2 Nodes.  You can increase the nodes in the Vagrantfile if need be.  There are many
ways to install kubernetes,  ```kubeadm init``` is used here

Vagrant script will do the following.
- Build the required Virtual Machines using Virtualbox
- Update the ubuntu linux and prepare for kubernetes
- Install all kubernetes and docker software
- Configure & Build kubernetes Control Plane
- Configure nodes and join cluster

If you are going to work with Kubernetes, you must familiarise yourself with 
the kubernetes documentation - which is excellent.

https://kubernetes.io/docs/home/

Read the install scripts in ```ubuntu/vagrant``` for more information on the install process

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
   - kmaster
   - knode01
   - knode02

  
  
  You can build all at once or one at a time.  The vm's are built using Centos and the first time you run vagrant, it will fetch the Centos image if it is not there.
  
  Build command is 

  `vagrant up <host, host> [default build everything.]`
   
   For the purpose of this excercise, we will build  kmaster & knode01
   
   `vagrant up kmaster knode01`



## Logging on to kmaster host 

   Each vm is created with user/password vagrant. 
   PLEASE DO NOT USE IN PRODUCTION.

   `vagrant ssh kmaster`

   You can also run `ssh vagrant@kmasterIP `

 

## Verification Checks 

After you have joined all the knodes, you can run a few commands to check the status of the cluster.

- `kubectl get nodes`
- `kubectl cluster-info`
- `kubectl get pods --all-namespaces`


### Sample output
```
[vagrant@kmaster ~]$ kubectl get nodes
NAME       STATUS   ROLES    AGE     VERSION
kmaster    Ready    master   4m30s   v1.19.3
knode01   Ready    <none>   81s     v1.19.3


vagrant@kmaster ~]$ kubectl cluster-info
Kubernetes master is running at https://10.1.1.10:6443
KubeDNS is running at https://10.1.1.10:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.



[vagrant@kmaster ~]$ kubectl get pods --all-namespaces
NAMESPACE     NAME                              READY   STATUS    RESTARTS   AGE
kube-system   coredns-f9fd979d6-2cxt4           1/1     Running   0          7m39s
kube-system   coredns-f9fd979d6-xxcr5           1/1     Running   0          7m39s
kube-system   etcd-kmaster                      1/1     Running   0          7m49s
kube-system   kube-apiserver-kmaster            1/1     Running   0          7m49s
kube-system   kube-kmasterler-manager-kmaster   1/1     Running   0          7m48s
kube-system   kube-proxy-4bd4m                  1/1     Running   0          7m39s
kube-system   kube-proxy-vvftg                  1/1     Running   0          4m49s
kube-system   kube-scheduler-kmaster            1/1     Running   0          7m49s
kube-system   weave-net-4xr72                   2/2     Running   0          5m54s
kube-system   weave-net-j49t2                   2/2     Running   1          4m49s


```

## Test your cluster.

```
kubectl run nginx --image=nginx
kubectl run nginx1 --image=nginx
kubectl get pods 
```
