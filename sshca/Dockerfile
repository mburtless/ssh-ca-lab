FROM sickp/alpine-sshd:latest
COPY sshca-keys /etc/ssh/
RUN echo "HostCertificate /etc/ssh/ssh_host_rsa_key-cert.pub" >> /etc/ssh/sshd_config
