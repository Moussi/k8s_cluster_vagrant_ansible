
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
# ansible command line
## Ping nodes
```aidl
ansible -i inventaire.ini -m ping http1 --user root --ask-pass
```

## generate password
```aidl
ansible localhost -i inventory.ini -m debug -a "msg={{'passforce' | password_hash('sha512', 'secretsalt')}}"
```

## create ansible user
```aidl
ansible -i inventory.ini -m user -a 'name=user-ansible password=$6$secretsalt$X5YDmUgDphPxnMkByvHbNaiP4T5Uk0WjEZ9TukWKQnXmXN81jG3DcGZnNJiSz9ltgPhplH92HOR/RqgmyS.zN1' --user root --ask-pass all
```

## disable fngerprint check
```aidl
export ANSIBLE_HOST_KEY_CHECKING=False
```
## add user-ansible to sudoers
```aidl
# Centos
ansible -i inventory.ini -m user -a 'user=user-ansible groups=wheel append=yes' --user root all
# Debian/Ubuntu
ansible -i inventory.ini -m user -a 'user=user-ansible groups=root append=yes' --user root all
```

## generae ssh keys
```aidl
ssh-keygen -t ecdsa
```

## add public key to authorized keys in nodes
```aidl
ansible -i inventory.ini -m authorized_key -a 'user=user-ansible state=present key="{{ lookup("file", "/home/moussi/Desktop/Projects/ansible/ssh_keys/id_ecdsa.pub") }}"' --user user-ansible --ask-pass --become --ask-become-pass all
```

## generate encrypted password via ansible-vault
```aidl
// using Ansible2019 password
 ansible-vault encrypt_string 'admin' --name 'mediawiki_admin_password'
```

## Disable security controls for testing

disable  SElinux :  ```setenforce 0  ;```  

disable  SElinux definitely : edit file  ```/etc/selinux/config```  and add this line ```SELINUX=permissive ;```  

disable firewalling : ```systemctl stop firewalld.service```  

disable firewalling : ```systemctl disable firewalld.service```

## run  Playbook
```aidl
ansible-playbook -i inventory.ini --user user-ansible --become --ask-become-pass install-apache.yml 
ansible-playbook -i inventory.ini --user user-ansible --become --ask-become-pass install-mariadb.yml
ansible-playbook -i inventory.ini --user user-ansible --become --ask-become-pass --ask-vault-pass install-mediawiki.yml
```

## ping nodes
```aidl
ansible -i inventory.ini all -m ping -vvv --user user-ansible
```