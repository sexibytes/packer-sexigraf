# https://github.com/netdata/netdata/tree/master/packaging/installer#automatic-one-line-installation-script
# DEBIAN_FRONTEND=noninteractive  apt-get -y install autoconf-archive autogen cmake libjudy-dev liblz4-dev libmnl-dev libuv1-dev python3-pymongo
# 
wget https://my-netdata.io/kickstart.sh -O /root/kickstart.sh
bash /root/kickstart.sh all --dont-wait --non-interactive --no-updates --stable-channel
# bash <(curl -Ss https://my-netdata.io/kickstart.sh) all --dont-wait --non-interactive --no-updates --stable-channel
# https://github.com/netdata/netdata/issues/1735
# sed -i -e "s/# x-frame-options response header =/x-frame-options response header = sameorigin/g" /etc/netdata/netdata.conf
# sed -i -e "s/# hostname = sexigraf/# hostname = sexigraf\n          bind socket to IP = 127.0.0.1/g" /etc/netdata/netdata.conf
# 
# You can opt out from anonymous statistics via the --disable-telemetry option, or by creating an empty file /etc/netdata/.opt-out-from-anonymous-statistics
touch /etc/netdata/.opt-out-from-anonymous-statistics
#
# systemctl restart netdata
rm -f /root/kickstart.sh