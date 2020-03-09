# https://github.com/netdata/netdata/tree/master/packaging/installer#automatic-one-line-installation-script
# DEBIAN_FRONTEND=noninteractive  apt-get -y install autoconf-archive autogen cmake libjudy-dev liblz4-dev libmnl-dev libuv1-dev python3-pymongo
# 
bash <(curl -Ss https://my-netdata.io/kickstart.sh) all --dont-wait --non-interactive --no-updates --stable-channel
# https://github.com/netdata/netdata/issues/1735
sed -i -e "s/# x-frame-options response header =/x-frame-options response header = sameorigin/g" /etc/netdata/netdata.conf
sed -i -e "s/# hostname = sexigraf/# hostname = sexigraf\n          bind socket to IP = 127.0.0.1/g" /etc/netdata/netdata.conf
# 
systemctl restart netdata