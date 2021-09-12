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
- Install Weave CNI 

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

#NOTE. Bridged adapter selection.

When you first run `vagrant up kmaster` it is most likely that you will be prompted 
to manually select the bridged adapter.   Make a note of the adapter name in the 
prompt and  replace "enp66s0" with the correct adapter for your system, in the following line of the Vagrantfile

```angular2html
# Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  config.vm.network "public_network",bridge: "enp66s0"
                                              ^^^^^^^
```
## Build the kubernetes VM's


   The vm names configured in the Vagrantfile are:
   - kmaster
   - knode01
   - knode02

  
  
Build the kmaster first before the nodes.  The kmaster build writes the output
of the kubeadm init command which is needed for the nodes to join the cluster

  Build kmaster first

  `vagrant up kmaster`
   
Build the nodes after you have successfully built kmaster   

   `vagrant up  knode01 knode02`



## Logging on to kmaster host 

   Each vm is created with user/password vagrant. 
   PLEASE DO NOT USE IN PRODUCTION.

   `vagrant ssh kmaster`

   You can also run `ssh vagrant@kmasterIP `

## Install Weave CNI

The script, install-CNI-Weave.sh is run during the build on kmaster.
```angular2html
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

## Verification Checks 

After you have joined all the knodes, you can run a few commands to check the status of the cluster.

- `kubectl get nodes`
- `kubectl cluster-info`
- `kubectl get pods --all-namespaces`


### Sample output

List all the nodes.

```
vagrant@kmaster:~$ kubectl get nodes
NAME      STATUS   ROLES                  AGE     VERSION
kmaster   Ready    control-plane,master   7m16s   v1.22.1
knode01   Ready    <none>                 3m55s   v1.22.1
knode02   Ready    <none>                 59s     v1.22.1
```
Show the clusterinfo

```
vagrant@kmaster:~$ kubectl cluster-info
Kubernetes control plane is running at https://192.168.56.2:6443
CoreDNS is running at https://192.168.56.2:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```
List pods in all namespaces

```
vagrant@kmaster:~$ kubectl get pods -A
NAMESPACE     NAME                              READY   STATUS    RESTARTS        AGE
kube-system   coredns-78fcd69978-pdrbx          1/1     Running   0               8m50s
kube-system   coredns-78fcd69978-qq9mb          1/1     Running   0               8m50s
kube-system   etcd-kmaster                      1/1     Running   0               9m4s
kube-system   kube-apiserver-kmaster            1/1     Running   0               9m2s
kube-system   kube-controller-manager-kmaster   1/1     Running   0               9m4s
kube-system   kube-proxy-fpwjh                  1/1     Running   0               2m49s
kube-system   kube-proxy-p72q2                  1/1     Running   0               8m51s
kube-system   kube-proxy-txfgk                  1/1     Running   0               5m45s
kube-system   kube-scheduler-kmaster            1/1     Running   0               9m2s
kube-system   weave-net-4pxpg                   2/2     Running   1 (8m35s ago)   8m51s
kube-system   weave-net-h5l2v                   2/2     Running   0               5m45s
kube-system   weave-net-mbdlk                   2/2     Running   0               2m49s

```

## Test your cluster.

```
kubectl run nginx --image=nginx
kubectl run nginx1 --image=nginx
```
```
vagrant@kmaster:~$ kubectl get pods -o wide
NAME     READY   STATUS    RESTARTS   AGE   IP          NODE      NOMINATED NODE   READINESS GATES
nginx    1/1     Running   0          30s   10.32.0.2   knode01   <none>           <none>
nginx1   1/1     Running   0          25s   10.32.0.2   knode02   <none>           <none>

```

Delete the pods
```angular2html
vagrant@kmaster:~$ kubectl delete pods nginx nginx1
pod "nginx" deleted
pod "nginx1" deleted

```

## Useful links
Kelsey Hightowers kubernetes the hard way is an excellent link for getting started and is recommended by the Linux Foundation CKA training.
[Kubernetes the hard way](URL 'https://github.com/kelseyhightower/kubernetes-the-hard-way')

To get started on installing Kubernetes, take a look [here](URL 'https://kubernetes.io/docs/setup/')

Kubernetes API Server validates and configures data for pods, services, replication etc.  
The API server is accessed by REST.   [more info here](URL 'https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/')

## Tips

- Run the following command on your master create command completion for kubectl
  - `kubectl completion bash >/etc/bash_completeion.d/kubectl`

## Troubleshooting VirtualBox
- I have found during developing with VM's, creating and deleting VM's can sometimes cause strange behaviour with Virtualbox or your vms.  When this happens before you rebuild or delete anythin, try rebooting your host.  This usually worked for me.
- 