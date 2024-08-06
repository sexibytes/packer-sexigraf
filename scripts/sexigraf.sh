# retrieve and unzip source
echo "Retrieving SexiGraf sources"
#
wget -q --no-proxy https://github.com/sexibytes/sexigraf/archive/devel.zip -O /tmp/sexigraf-src.zip
unzip /tmp/sexigraf-src.zip -d /tmp/

# Create empty folder for logs
mkdir -p /var/log/sexigraf/
mkdir -p /var/log/sexigraf/graphite/
chown -R www-data:root /var/log/sexigraf/graphite/
mkdir -p /var/log/sexigraf/carbon/
mkdir -p /var/log/collectd
#
apt-get update -y
# DEBIAN_FRONTEND=noninteractive apt-get -y -t unstable --no-install-recommends install graphite-carbon graphite-web collectd
# DEBIAN_FRONTEND=noninteractive apt-get -y install libhtml-template-perl libnumber-bytes-human-perl xml-twig-tools libsnmp30 cpanminus genisoimage collectd lib32z1 lib32ncurses5 build-essential uuid uuid-dev libssl-dev perl-doc libxml-libxml-perl libcrypt-ssleay-perl libsoap-lite-perl libmodule-build-perl libxml2 cpanminus sysstat snmp memcached net-tools
DEBIAN_FRONTEND=noninteractive apt-get -y install xml-twig-tools genisoimage collectd-core lib32z1 build-essential uuid uuid-dev libssl-dev libxml2 sysstat snmp memcached net-tools snmp-mibs-downloader

/bin/cp -rf /tmp/sexigraf-devel/etc/* /etc/
/bin/cp -rf /tmp/sexigraf-devel/usr/* /usr/
/bin/cp -rf /tmp/sexigraf-devel/var/* /var/
/bin/cp -rf /tmp/sexigraf-devel/opt/* /opt/

/bin/mv /opt/sexigraf/powershell.config.json /opt/microsoft/powershell/7-lts/

# randomize SECRET_KEY
sed -i -e "s/Sex1Gr4f/`date | md5sum | cut -d ' ' -f 1`/" /opt/graphite/webapp/graphite/local_settings.py
# moving carbon from single node to relay + dual node
cp /usr/local/src/carbon/distro/debian/init.d/carbon-relay /etc/init.d/carbon-relay
sed -i '/^#!\/bin\/bash/a ### BEGIN INIT INFO\n# Provides:          carbon-relay\n# Required-Start:    $remote_fs $syslog\n# Required-Stop:     $remote_fs $syslog\n# Default-Start:     2 3 4 5\n# Default-Stop:      0 1 6\n# Short-Description: Start carbon-relay at boot time\n# Description:       Enable service provided by carbon-relay\n### END INIT INFO' /etc/init.d/carbon-relay
chmod +x /etc/init.d/carbon-relay
update-rc.d carbon-relay defaults
service carbon-cache restart
service carbon-relay start

echo "Switching Grafana logo to SexiGraf one"
mv /usr/share/grafana/public/img/grafana_icon.svg /usr/share/grafana/public/img/grafana_icon_orig.svg
ln -s /usr/share/grafana/public/img/sexigraf.svg /usr/share/grafana/public/img/grafana_icon.svg

# echo "Intialise empty credentials store"
# mkdir -p /var/www/.vmware/credstore

# cat >/var/www/.vmware/credstore/vicredentials.xml <<EOL
# <?xml version="1.0" encoding="UTF-8"?>
# <viCredentials>
#     <version>1.1</version>
# </viCredentials>
# EOL

chown -R www-data. /var/www/
chown root:grafana /etc/grafana/provisioning/dashboards/*.yaml

# https://github.com/grafana/grafana/issues/15647
sed -i 's/;disable_sanitize_html = false/disable_sanitize_html = true/g' /etc/grafana/grafana.ini
# customizing grafana
sed -i 's/;reporting_enabled = true/reporting_enabled = false/g' /etc/grafana/grafana.ini
sed -i 's/;check_for_updates = true/check_for_updates = false/g' /etc/grafana/grafana.ini
sed -i 's/;disable_gravatar = false/disable_gravatar = true/g' /etc/grafana/grafana.ini
sed -i 's/;http_addr =/http_addr = 127.0.0.1/g' /etc/grafana/grafana.ini
# sed -i 's/;force_migration = false/force_migration = true/g' /etc/grafana/grafana.ini
sed -i 's/;max_annotation_age =/max_annotation_age = 1y/g' /etc/grafana/grafana.ini
sed -i 's/;max_annotations_to_keep =/max_annotations_to_keep = 9999/g' /etc/grafana/grafana.ini
# disabling unified_alerting
# sed -i 's/\[unified_alerting\]/[unified_alerting]\nenabled = false/g' /etc/grafana/grafana.ini
# sed -i 's/\[alerting\]/[alerting]\nenabled = false/g' /etc/grafana/grafana.ini
# enabling unified_alerting.screenshots capture
cat >>/etc/grafana/grafana.ini <<EOL
# Enable screenshots in notifications
[unified_alerting.screenshots]
capture = true
EOL

# https://marcus.se.net/grafana-csv-datasource/
mkdir -p /mnt/wfs/inventory/
mv /opt/sexigraf/*.csv /mnt/wfs/inventory/
echo "[plugin.marcusolsson-csv-datasource]" >> /etc/grafana/grafana.ini
echo "allow_local_mode = true" >> /etc/grafana/grafana.ini
systemctl restart grafana-server
sleep 10s
#
curl --noproxy localhost -H "Content-Type: application/json" -X POST -d '{"name":"ViVmCsv","type":"marcusolsson-csv-datasource","isDefault":false,"access":"proxy","url":"/mnt/wfs/inventory/ViVmInventory.csv","password":"","user":"","database":"","basicAuth":false,"isDefault":false,"jsonData":{"storage":"local"}}' http://admin:admin@localhost:3000/api/datasources
sleep 1s
#
curl --noproxy localhost -H "Content-Type: application/json" -X POST -d '{"name":"ViEsxCsv","type":"marcusolsson-csv-datasource","isDefault":false,"access":"proxy","url":"/mnt/wfs/inventory/ViEsxInventory.csv","password":"","user":"","database":"","basicAuth":false,"isDefault":false,"jsonData":{"storage":"local"}}' http://admin:admin@localhost:3000/api/datasources
sleep 1s
#
curl --noproxy localhost -H "Content-Type: application/json" -X POST -d '{"name":"ViDsCsv","type":"marcusolsson-csv-datasource","isDefault":false,"access":"proxy","url":"/mnt/wfs/inventory/ViDsInventory.csv","password":"","user":"","database":"","basicAuth":false,"isDefault":false,"jsonData":{"storage":"local"}}' http://admin:admin@localhost:3000/api/datasources
sleep 1s
#
curl --noproxy localhost -H "Content-Type: application/json" -X POST -d '{"name":"ViVbrCsv","type":"marcusolsson-csv-datasource","isDefault":false,"access":"proxy","url":"/mnt/wfs/inventory/VbrVmInventory.csv","password":"","user":"","database":"","basicAuth":false,"isDefault":false,"jsonData":{"storage":"local"}}' http://admin:admin@localhost:3000/api/datasources
sleep 1s
#
curl --noproxy localhost -H "Content-Type: application/json" -X POST -d '{"name":"ViSnapCsv","type":"marcusolsson-csv-datasource","isDefault":false,"access":"proxy","url":"/mnt/wfs/inventory/ViSnapInventory.csv","password":"","user":"","database":"","basicAuth":false,"isDefault":false,"jsonData":{"storage":"local"}}' http://admin:admin@localhost:3000/api/datasources
sleep 1s
#
echo "Grafana default configuration completed, switching default password"
curl --noproxy localhost -H "Content-Type: application/json" -X PUT -d '{"oldPassword":"admin","newPassword":"Sex!Gr@f","confirmNew":"Sex!Gr@f"}' http://admin:admin@localhost:3000/api/user/password
sleep 1s
# 

mkdir -p /etc/apache2/ssl

openssl req -newkey rsa:4096 -days 3650 -nodes -x509 -subj "/C=FR/ST=Paris/L=Paris/O=SexiBytes/OU=SexiDevs/CN=sexigraf.sexibyt.es/emailAddress=plot@sexigraf.fr" -keyout /etc/apache2/ssl/sexigraf.key -out /etc/apache2/ssl/sexigraf.crt

a2enmod proxy
a2enmod proxy_http
a2enmod ssl
a2enmod socache_shmcb
a2enmod rewrite

chmod a+x /opt/sexigraf/*.ps1

echo "Intialise empty PS credentials stores"
/usr/bin/pwsh -f /opt/sexigraf/CredstoreAdmin.ps1 -createstore -credstore /mnt/wfs/inventory/vipscredentials.xml
chown www-data:www-data /mnt/wfs/inventory/vipscredentials.xml
/usr/bin/pwsh -f /opt/sexigraf/CredstoreAdmin.ps1 -createstore -credstore /mnt/wfs/inventory/vbrpscredentials.xml
chown www-data:www-data /mnt/wfs/inventory/vbrpscredentials.xml

mkdir -p /var/log/sexigraf
mkdir -p /var/log/apache2/graphite

# Configure crontab for vmtools infos
echo "\n@reboot         root    /usr/bin/pwsh -NonInteractive -NoProfile -f /opt/sexigraf/PullGuestInfo.ps1 >/dev/null 2>&1" >> /etc/crontab
#
echo "SexiDone"