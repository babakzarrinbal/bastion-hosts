#!/bin/sh
# Author: Babak Zarrinbal
# Date: 2024-09-19
# requirments:
#  ENV variables:
#   - AUTHORIZED_KEYS   [optional]
#   - SSH_HOST_RSA_KEY_PUB  [optional]
#   - SSH_HOST_RSA_KEY  [optional]


# Modify AllowTcpForwarding to yes
sed -i 's/^AllowTcpForwarding .*/AllowTcpForwarding yes/' /etc/ssh/sshd_config


# Write authorized keys to ~/.ssh/authorized_keys
if [ -n "$AUTHORIZED_KEYS" ]; then
    echo "Writing authorized keys to /root/.ssh/authorized_keys"
    echo "$AUTHORIZED_KEYS" > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    chown root:root /root/.ssh/authorized_keys
    # Modify PasswordAuthentication to no
    sed -i '/^[[:space:]]*#\?[[:space:]]*PasswordAuthentication/s/.*/PasswordAuthentication no/' /etc/ssh/sshd_config
else
    echo "No authorized keys provided Login with password is enabled"
fi

# Create SSH host key files from environment variables
if [ -n "$SSH_HOST_RSA_KEY" ] && [ -n "$SSH_HOST_RSA_KEY_PUB" ]; then
    echo "Writing SSH host key files from environment variables"
    echo "$SSH_HOST_RSA_KEY" > /etc/ssh/ssh_host_rsa_key
    echo "$SSH_HOST_RSA_KEY_PUB" > /etc/ssh/ssh_host_rsa_key.pub
    chmod 600 /etc/ssh/ssh_host_rsa_key
    chmod 644 /etc/ssh/ssh_host_rsa_key.pub
    chown root:root /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key.pub
else
    echo "No SSH host key files provided. Generating new ones."
    ssh-keygen -A
fi

echo "Starting SSH service"
/usr/sbin/sshd -D