export KUBECONFIG=/etc/kubernetes/admin.conf
#kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

kubectl create -f https://git.io/weave-kube
