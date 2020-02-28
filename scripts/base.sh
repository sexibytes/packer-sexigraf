# Update the box
DEBIAN_FRONTEND=noninteractive apt-get -y update
# apt-get -y install linux-headers-$(uname -r) build-essential
# apt-get -y install zlib1g-dev libssl-dev libreadline-gplv2-dev
DEBIAN_FRONTEND=noninteractive apt-get -y install curl unzip resolvconf console-setup apt-transport-https vim wget htop

# Tweak sshd to prevent DNS resolution (speed up logins)
# echo 'UseDNS no' >> /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config


# vmwgfx.enable_fbdev=1
# https://communities.vmware.com/thread/514376
