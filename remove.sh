#!/usr/bin/env bash

# Remove all ssh key subdirectories
find . -name \*keys -type d -exec rm -r "{}" \;

# Remove old server_ca public key from client1 dockerfile
head -n -1 client1/Dockerfile > TempDockerfile ; mv TempDockerfile client1/Dockerfile
