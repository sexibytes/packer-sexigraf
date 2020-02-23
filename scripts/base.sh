# Update the box
DEBIAN_FRONTEND=noninteractive apt-get -y update
# apt-get -y install linux-headers-$(uname -r) build-essential
# apt-get -y install zlib1g-dev libssl-dev libreadline-gplv2-dev
DEBIAN_FRONTEND=noninteractive apt-get -y install curl unzip resolvconf console-setup apt-transport-https vim wget

# Tweak sshd to prevent DNS resolution (speed up logins)
echo 'UseDNS no' >> /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Remove 5s grub timeout to speed up booting
cat <<EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="debian-installer=en_US ipv6.disable=1 vmwgfx.enable_fbdev=1"
EOF

update-grub
# https://communities.vmware.com/thread/514376