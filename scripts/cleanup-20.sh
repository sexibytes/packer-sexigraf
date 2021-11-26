# Clean up
# apt-get -y remove linux-headers-$(uname -r) build-essential
# Remove non-critical packages
# https://wiki.debian.org/ReduceDebian
#apt-get purge $(aptitude search '~i!~M!~prequired!~pimportant!~R~prequired!~R~R~prequired!~R~pimportant!~R~R~pimportant!busybox!grub!initramfs-tools!aptitude!open-vm-tools!openssh-server!dmsetup!libffi6!sudo' | awk '{print $2}')
#apt-get purge aptitude

# DEBIAN_FRONTEND=noninteractive apt-get -y purge acpi acpi-support-base acpid bzip2 console-setup console-setup-linux discover gcc man-db manpages nano libglib2.0-data installation-report keyboard-configuration laptop-detect linux-image-amd64 locales lvm2 pciutils rsync ssl-cert task-english

# DEBIAN_FRONTEND=noninteractive apt-get -y autoremove --purge
# DEBIAN_FRONTEND=noninteractive apt-get -y clean

# Removing leftover leases and persistent rules
# echo "cleaning up dhcp leases"
# rm /var/lib/dhcp/*

# Make sure Udev doesn't block our network
# echo "cleaning up udev rules"
# rm /etc/udev/rules.d/70-persistent-net.rules
# mkdir /etc/udev/rules.d/70-persistent-net.rules
# rm -rf /dev/.udev/
# rm /lib/udev/rules.d/75-persistent-net-generator.rules

# echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
# echo "pre-up sleep 2" >> /etc/network/interfaces

echo "purge locale"
find /usr/share/locale/* -maxdepth 0 -name 'en_US' -prune -o -exec rm -rf '{}' ';'

echo "Remove foreign language man files"
rm -rf /usr/share/man/??
rm -rf /usr/share/man/??_*

echo "Clean doc files"
rm -rf /usr/share/doc/*

echo "Clean up log files"
find /var/log -type f | while read f; do echo -ne '' > $f; done;
find /opt/graphite/storage/log -type f | while read f; do echo -ne '' > $f; done;

echo "Clean apt files"
rm -rf /var/lib/apt/lists/*

echo "Remove temp files before compacting"
rm -rf /tmp/*
rm -rf /usr/local/src/*
rm -rf /opt/graphite/storage/whisper/*
if [ -d "/mnt/wfs/whisper" ]; then
    rm -rf /mnt/wfs/whisper/*
fi

# disable netplan
apt -y purge netplan.io

cat >/etc/network/interfaces <<EOL
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet dhcp
pre-up sleep 2
EOL

echo "Purge possible proxy info"
rm -rf /etc/apt/apt.conf

# echo "remove popularity-contest"
rm -f /etc/cron.d/popularity-contest

echo "zeroing free space"
cd /root
cat /dev/zero >zero.fill &>/dev/null; sleep 1; sync; sleep 1; /bin/rm -f zero.fill
# cat /dev/null > ~/.bash_history && history -c && exit