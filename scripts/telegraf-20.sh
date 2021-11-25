#!/bin/bash
echo "install telegraf"
wget -qO- https://repos.influxdata.com/influxdb.key | apt-key add -
echo "deb https://repos.influxdata.com/ubuntu focal stable" > /etc/apt/sources.list.d/influxdb.list
#
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y telegraf
systemctl start telegraf
#
echo "install ipmitool"
# DEBIAN_FRONTEND=noninteractive apt-get install -y ipmitool
# update-rc.d openipmi disable