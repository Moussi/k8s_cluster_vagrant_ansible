
# create vms and users

```shell script
cd vagrant
vagrant up

```
* add manualy authorized keys to authorize user-ansible to connect
* configure static ip addresses https://linuxconfig.org/how-to-configure-static-ip-address-on-ubuntu-18-04-bionic-beaver-linux

# Prepare ansible packages via python 

```shell script
virtualenv -p python3 py37-ansible
pip install -r shared/requirements.txt
. py37-ansible/bin/activate
```


# Docker Setup in each node
https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
```shell script
see vagrant/setup_docker.sh
```

# Kubernetes

## hard way install
https://github.com/kelseyhightower/kubernetes-the-hard-way
## networking
```shell script
wget https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
wget https://docs.projectcalico.org/latest/manifests/calico.yaml 

kuebadmin init --pod-network-cidr=192.168.0.0/16
kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=172.16.94.10
# check CALICO_IPV4POOL_CIDR in calico.yml file must be the same as pod network cidr

kubectl apply -f rbac-kdd.yaml
kubectl apply -f calico.yaml

```

## Create master

```shell script
kubectl get pods --all-namespaces 
kubectl get pods --all-namespaces --watch (live monitoring)
kubectl get nodes

# get tokens list
kubeadm token list
kubeadm token create --print-join-command
```
## Join nodes
```shell script
kubeadmin join <master_ip>:6443 \
    -- token <token>
    --discovery-token-ca-cert-hash sha256:#PASTE_HASH_HERE

# get ca cert HASH from master
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //' 
```

# kubectl
https://kubernetes.io/docs/reference/kubectl/kubectl/
https://kubernetes.io/docs/reference/kubectl/cheatsheet/

## Using kubectl: Nodes, Pods, and API Resources
Listing and Inspecting your cluster, pods, services and more.
```shell script
kubectl cluster-info
#To further debug and diagnose cluster problems
kubectl cluster-info dump
```
Additional information about each node in the cluster. 
```shell script
kubectl get nodes -o wide
```
Get a list of system pods. A namespace is a way to group resources together.
```shell script
kubectl get pods --namespace kube-system
```
Get additional information about each pod. 
```shell script
kubectl get pods --namespace kube-system -o wide
```

Asking kubernetes for the resources it knows about
Headers : Name, Alias/shortnames, API Group (or where that resource is in the k8s API Path),
Is the resource in a namespace, for example StorageClass issn't and is available to all namespaces and finally Kind...this is the object type.

```shell script
kubectl api-resources | head -n 10
```

Get a list of everything that's running in all namespaces
```shell script
kubectl get all --all-namespaces | more
```

Explain specific resource in details
```shell script
kubectl explain pod | more
kubectl explain pod.spec | more
kubectl explain pod.spec.containers | more
```

Check out Name, Taints, Conditions, Addresses, System Info, Non-Terminated Pods, and Events
```shell script
kubectl describe nodes master1
kubectl describe no master1 (alias)
kubectl describe nodes node1
```

enable bash auto-complete of our kubectl commands
```shell script
sudo apt-get install bash-completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc
kubectl g[tab][tab] po[tab][tab] --all[tab][tab]
```
Help
```shell script
kubectl -h | more
kubectl get -h | more
kubectl describe -h | more
```

## Imperative Deployments and Working with Resources in Your Cluster
Executing commands at the command line one at a time, and you're going to be operating on one object at a time.
```shell script
kubectl create deployment nginx --image=nginx

```
follow our pod and deployment status
```shell script
kubectl get pods
kubectl get deployment
kubectl get pods -o wide
kubectl describe pods $PASTEPODNAMEHERE
kubectl logs nginx
```

## Looking Closer at Resources and Exposing and Accessing Services in Your Cluster
expose service
```shell script
kubectl create service nodeport nginx --tcp=80:80
kubectl expose deployment hello-world --type=NodePort --name=example-service
```
## Declarative Deployments and Accessing and Modifying Existing Resources in Your Cluster
We can define our configurations in code using manifests written in YAML or JSON, and feed those into the API server with commands like kubectl apply. In this case here, you can see kubectl apply -f deployment.yaml and the contents of deployment.yaml will have the description of the thing that I want to deploy inside of Kubernetes.  
The API server will go and make that the deployment for us.  

Using kubectl to generate yaml or json files of our imperitive configuration.

```
kubectl get service hello-world -o yaml
kubectl get service hello-world -o json
```

Exported resources are stripped of cluster-specific information.
```
kubectl get service hello-world -o yaml --export > service-hello-world.yaml
kubectl get deployment hello-world -o yaml --export > deployment-hello-world.yaml
ls *.yaml
more service-hello-world.yaml
```

We can ask the API for more information about an object
```
kubectl explain service | more
```

explanation of what's available for that resource
```
kubectl explain service.spec | more
kubectl explain service.spec.ports
kubectl explain service.spec.ports.targetPort
```

Let's remove everything we created with impretaive deployment and start over using a declarative model
```
kubectl delete service hello-world
kubectl delete deployment hello-world
kubectl delete pod hello-world-pod
kubectl get all
```

we can use apply to create our resources from yaml.
```
kubectl apply -f deployment-hello-world.yaml
kubectl apply -f service-hello-world.yaml
```
This re-creates everything we created, but in yaml
```
kubectl get all
```

scale up our deployment
```
vi deployment-hello-world.yaml
Change replicas from 1 to 2
     replicas: 2
```

update our configuration with apply
```
kubectl apply -f deployment-hello-world.yaml
```

And check the current configuration of our deployment
```
kubectl get deployment hello-world
```

Repeat the curl access to see the load balancing of the HTTP request
```
kubectl get service hello-world
curl http://$SERVICEIP:PORT
```

We can edit the resources "on the fly" with kubectl edit. But this isn't reflected in our yaml. But is
persisted in the etcd database...cluster store. Change 2 to 3.
```
kubectl edit deployment hello-world
```

Let's clean up our deployment and remove everything
```
kubectl delete deployment hello-world
kubectl delete service hello-world
kubectl get all
```


## Application deployment process
Now let's say we have a cluster, and we're sitting at the command line running kubectl, and we want to deploy an  
application into Kubernetes and we say kubectl apply, and we pass in some sort of manifest describing the objects that  
we want to create.  
Let's say we want to create a pod that's in a replica set. So what's going to happen:
1. First is kubectl apply is going to send that information into the API server. 
2. The API server is going to parse that information and store those objects persistently in the cluster store.  
3. The controller manager is going to be watching the cluster store and asking, do you have an information for me.  
4. Since we defined a replica set, it's going to start up a controller for that particular replica set.  
5. That replica set is then going to start up the required number of pods to support that configuration.  
6. The scheduler has the job of picking which nodes the pods are going to go on. 
7. The scheduler is going to message to the API server and store the information about what nodes it wants to start which pods on. 
8. Now the kubelets on the nodes are watching the API server saying, do you have any work for me? 
9. if it messages the API server and says, do you have any work, and it finds that there's a pod scheduled for it,   
then it's going to send a message to the container runtime on that node to pull down the appropriate container specified  
in that pod and start up the pod.  


