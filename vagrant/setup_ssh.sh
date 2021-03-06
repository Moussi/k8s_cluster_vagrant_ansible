#!/bin/bash

ROOT_HOME="/root"
ROOT_SSH_HOME="$ROOT_HOME/.ssh"
ROOT_AUTHORIZED_KEYS="$ROOT_SSH_HOME/authorized_keys"
VAGRANT_HOME="/home/vagrant"
VAGRANT_SSH_HOME="$VAGRANT_HOME/.ssh"
VAGRANT_AUTHORIZED_KEYS="$VAGRANT_SSH_HOME/authorized_keys"

USER="amoussi"
USER_HOME="/home/$USER"
USER_SSH_HOME="$USER_HOME/.ssh"
USER_AUTHORIZED_KEYS="$USER_SSH_HOME/authorized_keys"

# Setup keys for root user.
ssh-keygen -C root@localhost -f "$ROOT_SSH_HOME/id_rsa" -q -N ""
cat "$ROOT_SSH_HOME/id_rsa.pub" >> "$ROOT_AUTHORIZED_KEYS"
chmod 644 "$ROOT_AUTHORIZED_KEYS"

# Setup keys for vagrant user.
ssh-keygen -C vagrant@localhost -f "$VAGRANT_SSH_HOME/id_rsa" -q -N ""
cat "$VAGRANT_SSH_HOME/id_rsa.pub" >> "$ROOT_AUTHORIZED_KEYS"
cat "$VAGRANT_SSH_HOME/id_rsa.pub" >> "$VAGRANT_AUTHORIZED_KEYS"
chmod 644 "$VAGRANT_AUTHORIZED_KEYS"
chown -R vagrant:vagrant "$VAGRANT_SSH_HOME"

# create user
useradd -ms /bin/bash -G root -d $USER_HOME $USER
usermod -aG sudo $USER
mkdir -p $USER_SSH_HOME
chmod 700 $USER_SSH_HOME
touch $USER_AUTHORIZED_KEYS
chown -R $USER:root $USER_SSH_HOME;chmod -R 700 $USER_SSH_HOME
cat "/vagrant/id_rsa.pub" >> "$USER_AUTHORIZED_KEYS"
cat "/vagrant/id_ecdsa.pub" >> "$USER_AUTHORIZED_KEYS"
echo "$USER  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER