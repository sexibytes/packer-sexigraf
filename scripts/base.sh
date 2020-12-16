# Update the box
DEBIAN_FRONTEND=noninteractive apt-get -y update
# apt-get -y install linux-headers-$(uname -r) build-essential
# apt-get -y install zlib1g-dev libssl-dev libreadline-gplv2-dev
DEBIAN_FRONTEND=noninteractive apt-get -y install curl unzip resolvconf console-setup apt-transport-https vim wget htop parted

# Tweak sshd to prevent DNS resolution (speed up logins)
# echo 'UseDNS no' >> /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config

# https://communities.vmware.com/thread/514376
# vmwgfx.enable_fbdev=1

# https://kb.vmware.com/s/article/2053145
echo "options vmw_pvscsi cmd_per_lun=254 ring_pages=32" > /etc/modprobe.d/pvscsi

if fdisk -l|grep -i "/dev/sdb" > /dev/null; then
# https://www.digitalocean.com/community/tutorials/how-to-partition-and-format-storage-devices-in-linux
# https://askubuntu.com/questions/384062/how-do-i-create-and-tune-an-ext4-partition-from-the-command-line
  echo "mount sdb"
  parted /dev/sdb mklabel gpt
  parted -a opt /dev/sdb mkpart primary ext4 0% 100%
  mkfs.ext4 -N 8388608 -L wfs /dev/sdb1
  mkdir -p /mnt/wfs
  echo "#" >> /etc/fstab
  echo "LABEL=wfs /mnt/wfs ext4 noatime,nodiratime,barrier=0,nobh,errors=remount-ro 0 1" >> /etc/fstab
  mount -a
  mkdir -p /mnt/wfs/whisper
fi