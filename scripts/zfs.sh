#https://github.com/openzfs/zfs/wiki/Building-ZFS
DEBIAN_FRONTEND=noninteractive  apt-get install -y build-essential autoconf automake libtool gawk alien fakeroot dkms libblkid-dev uuid-dev libudev-dev libssl-dev zlib1g-dev libaio-dev libattr1-dev libelf-dev linux-headers-$(uname -r) python3 python3-dev python3-setuptools python3-cffi libffi-dev parted
# 
cd /usr/local/src
git clone https://github.com/openzfs/zfs -b zfs-0.8-release
cd ./zfs
git checkout zfs-0.8.3
sh autogen.sh
./configure
make -s -j$(nproc)
make install
# 
# https://github.com/openzfs/zfs/issues/6577
ln -s /usr/local/lib/nvpair.a /usr/lib/nvpair.a
ln -s /usr/local/lib/libnvpair.la /usr/lib/libnvpair.a
ln -s /usr/local/lib/libnvpair.so /usr/lib/libnvpair.so
ln -s /usr/local/lib/libnvpair.so.1 /usr/lib/libnvpair.so.1
ln -s /usr/local/lib/libnvpair.so.1.0.1 /usr/lib/libnvpair.so.1.0.1
ln -s /usr/local/lib/libuutil.a /usr/lib/libuutil.a
ln -s /usr/local/lib/libuutil.la /usr/lib/libuutil.la
ln -s /usr/local/lib/libuutil.so /usr/lib/libuutil.so
ln -s /usr/local/lib/libuutil.so.1 /usr/lib/libuutil.so.1
ln -s /usr/local/lib/libuutil.so.1.0.1 /usr/lib/libuutil.so.1.0.1
ln -s /usr/local/lib/libzfs.a /usr/lib/libzfs.a
ln -s /usr/local/lib/libzfs_core.a /usr/lib/libzfs_core.a
ln -s /usr/local/lib/libzfs_core.la /usr/lib/libzfs_core.la
ln -s /usr/local/lib/libzfs_core.so /usr/lib/libzfs_core.so
ln -s /usr/local/lib/libzfs_core.so.1 /usr/lib/libzfs_core.so.1
ln -s /usr/local/lib/libzfs_core.so.1.0.0 /usr/lib/libzfs_core.so.1.0.0
ln -s /usr/local/lib/libzfs.la /usr/lib/libzfs.la
ln -s /usr/local/lib/libzfs.so /usr/lib/libzfs.so
ln -s /usr/local/lib/libzfs.so.2 /usr/lib/libzfs.so.2
ln -s /usr/local/lib/libzfs.so.2.0.0 /usr/lib/libzfs.so.2.0.0
# 
# https://github.com/openzfs/zfs/issues/8885
# 
if fdisk -l|grep -i "/dev/sdb" > /dev/null; then
  echo "enable zfs services"
  # 
  systemctl enable zfs-import.target
  systemctl enable zfs-mount.service
  systemctl enable zfs.target
  systemctl enable zfs-zed.service
  systemctl enable zfs-import-cache.service
  systemctl enable zfs-import-scan.service
  # 
  /sbin/modprobe zfs
  # 
  echo "mount sexipool"
  sleep 5s
  mkdir -p /zfs
  zpool create -fd -m /zfs sexipool /dev/sdb
  sleep 5s
  zfs create sexipool/whisper
  zpool set autoexpand=on sexipool
  # zpool set autotrim=on sexipool
  zfs set checksum=off sexipool
  zfs set atime=off sexipool
  zfs set sync=disabled sexipool
  # mkdir -p /zfs/whisper
  chmod 775 /zfs/whisper
  chown www-data:carbon /zfs/whisper
  chown -R carbon /zfs/whisper
  echo "change whisper folder"
  sed -i -e "s/#LOCAL_DATA_DIR = \/opt\/graphite\/storage\/whisper\//LOCAL_DATA_DIR = \/zfs\/whisper\//g" /opt/graphite/conf/carbon.conf
  sed -i -e 's/#WHISPER_DIR = '"'"'\/opt\/graphite\/storage\/whisper'"'"'/WHISPER_DIR = '"'"'\/zfs\/whisper'"'"'/g' /opt/graphite/webapp/graphite/local_settings.py
  # mv /opt/graphite/storage/whisper/*  /zfs/whisper/
  # https://kb.vmware.com/s/article/2053145
  echo "options vmw_pvscsi cmd_per_lun=254 ring_pages=32" > /etc/modprobe.d/pvscsi
fi