#!/usr/bin/env bash
# Author: Matthew Burtless
# Date: 4/7/2018
# Version: 1.0
# Description: Generate and sign all host, user and CA keys required for SSHD CA lab

# Function to generate all types of host keys
createhostkeys() {
	# Store current working dir
	old_pwd="$PWD"
	cd $1
	ssh-keygen -t dsa -N "" -C "dsa host key" -f ./ssh_host_dsa_key > /dev/null
	ssh-keygen -t rsa -N "" -C "rsa host key" -f ./ssh_host_rsa_key > /dev/null
	ssh-keygen -t ecdsa -N "" -C "ecdsa host key" -f ./ssh_host_ecdsa_key > /dev/null
	cd $old_pwd
}

# Function to generate rsa user keys
createuserkeys() {
	# Store current working dir
	old_pwd="$PWD"
	cd $1
	ssh-keygen -t rsa -N "" -C "user keys" -f ./id_rsa > /dev/null
	cd $old_pwd
}

# Function to generate CA keys
createcakeys() {
	# Store current working dir
	old_pwd="$PWD"
	cd $1
	ssh-keygen -N "" -C "server signing key" -f ./server_ca > /dev/null
	ssh-keygen -N "" -C "user signing key" -f ./users_ca > /dev/null
	cd $old_pwd
}


# Make necessary dirs
echo "Making directories to hold SSH keys for each container"

mkdir sshca/sshca-keys
mkdir server1/server1-keys
mkdir client1/client1-keys

echo "Generating host keys for sshca"
createhostkeys "sshca/sshca-keys"
echo "Generating host keys for server1"
createhostkeys "server1/server1-keys"

echo "Generating user keys for root on client1"
createuserkeys "client1/client1-keys"

echo "Generating server and user CA keys"
createcakeys "sshca/sshca-keys"

echo "Copying user CA public key to server1"
cp sshca/sshca-keys/users_ca.pub server1/server1-keys/

echo "Updating client1 Dockerfile with server CA public key"
sshca_pub=`cat sshca/sshca-keys/server_ca.pub`
echo "RUN echo \"@cert-authority * $sshca_pub\" >> /root/.ssh/known_hosts" >> client1/Dockerfile

echo "Signing CA host public key with server CA key"
ssh-keygen -s ./sshca/sshca-keys/server_ca -C "signed host key" -I host_auth_server -h -n sshca -V +52w ./sshca/sshca-keys/ssh_host_rsa_key.pub > /dev/null
ssh-keygen -s ./sshca/sshca-keys/server_ca -C "signed host key" -I host_auth_server -h -n sshca -V +52w ./sshca/sshca-keys/ssh_host_ecdsa_key.pub > /dev/null
echo "Signing server1 host public key with server CA key"
ssh-keygen -s ./sshca/sshca-keys/server_ca -C "signed host key" -I host_sshserver -h -n server1 -V +52w ./server1/server1-keys/ssh_host_rsa_key.pub > /dev/null
ssh-keygen -s ./sshca/sshca-keys/server_ca -C "signed host key" -I host_sshserver -h -n server1 -V +52w ./server1/server1-keys/ssh_host_ecdsa_key.pub > /dev/null
echo "Signing client1 root user public key with user CA key"
ssh-keygen -s ./sshca/sshca-keys/users_ca -C "signed user key" -I user_root -n root -V +52w ./client1/client1-keys/id_rsa.pub > /dev/null
