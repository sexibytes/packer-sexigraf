#!/bin/bash
echo "install telegraf"
#
curl -s https://repos.influxdata.com/influxdata-archive.key > /tmp/influxdata-archive.key
#
echo '943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515 /tmp/influxdata-archive.key' | sha256sum
cat /tmp/influxdata-archive.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' | tee /etc/apt/sources.list.d/influxdata.list
#
apt-get update
apt-get install telegraf -y
#
# echo "install ipmitool"
# DEBIAN_FRONTEND=noninteractive apt-get install -y ipmitool
# update-rc.d openipmi disable