#!/bin/bash
echo "install telegraf"
#
curl -s https://repos.influxdata.com/influxdata-archive_compat.key > /tmp/influxdata-archive.key
echo '393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c /tmp/influxdata-archive.key' | sha256sum -c
cat influxdata-archive_compat.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg > /dev/null
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' | sudo tee /etc/apt/sources.list.d/influxdata.list
#
apt-get update
apt-get install telegraf -y
#
# echo "install ipmitool"
# DEBIAN_FRONTEND=noninteractive apt-get install -y ipmitool
# update-rc.d openipmi disable