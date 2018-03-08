FROM sickp/alpine-sshd:latest
COPY server1-keys /etc/ssh/
RUN echo "TrustedUserCAKeys /etc/ssh/users_ca.pub" >> /etc/ssh/sshd_config &&\
    echo "HostCertificate /etc/ssh/ssh_host_rsa_key-cert.pub" >> /etc/ssh/sshd_config
