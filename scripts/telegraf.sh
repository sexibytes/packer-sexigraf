 echo "install telegraf"
wget -qO- https://repos.influxdata.com/influxdb.key | apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | tee /etc/apt/sources.list.d/influxdb.list
#
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y telegraf
systemctl start telegraf
#
echo "install ipmitool"
DEBIAN_FRONTEND=noninteractive apt-get install -y ipmitool