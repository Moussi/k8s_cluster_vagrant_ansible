
# create vms and users

```aidl
cd vagrant
vagrant up
add manualy authorized keys to authorize user-ansible to connect
```


# Prepare ansible packages via python 

```aidl
virtualenv -p python3 py37-ansible
pip install -r shared/requirements.txt
. py37-ansible/bin/activate
```

# Kubernetes
## networking
```buildoutcfg
wget https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
wget https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml

kuebadmin init --pod-network-cidr=192.168.0.0/16
# check CALICO_IPV4POOL_CIDR in calico.yml file must be the same as pod network cidr

kubectl apply -f rbac-kdd.yaml
kubectl apply -f calico.yaml

```

## Create master

