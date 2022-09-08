# retrieve and unzip source
echo "Retrieving SexiGraf sources"
#
wget -q --no-proxy https://github.com/sexibytes/sexigraf/archive/develop.zip -O /tmp/sexigraf-src.zip
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

# https://code.vmware.com/docs/6530/vsphere-sdk-for-perl-installation-guide/doc/GUID-16A5A35D-1E05-4DD4-8E02-BEA6BF24A77B.html
# https://vdc-repo.vmware.com/vmwb-repository/dcr-public/f280c443-0cda-4fed-8e15-7dc07e2b7037/66ce9472-ffd3-4e80-83b4-1bcfeec2099e/doc/GUID-8B0E6E94-A215-4904-935D-1B164C3941A8.html#GUID-8B0E6E94-A215-4904-935D-1B164C3941A8
# https://vdc-download.vmware.com/vmwb-repository/dcr-public/ae41a1d3-b1ac-4f7c-a1d4-4774ddd05e99/2d5ae4b7-d040-4de1-824d-eb339b09cf6e/vsphere-perl-sdk-67-release-notes.html#supported
# https://communities.vmware.com/message/2298661#2298661

# /bin/cp -rf /tmp/sexigraf-develop/root/* /root/
# tar -zxf /root/VMware-vSphere-Perl-SDK-7.0.0-17698549.x86_64.tar.gz -C /root/

# cpanm ExtUtils::MakeMaker
# cpanm Net::FTP
# cpanm Module::Build
# #
# cpanm Time::Piece
# cpanm Archive::Zip
# cpanm ExtUtils::Installed
# cpanm Path::Class
# cpanm Try::Tiny
# cpanm Crypt::SSLeay
# cpanm version
# cpanm Data::Dumper
# cpanm HTML::Parser
# cpanm UUID
# cpanm XML::SAX
# cpanm XML::NamespaceSupport
# cpanm XML::LibXML::Common
# cpanm XML::LibXML
# cpanm LWP
# cpanm LWP::Protocol::https
# cpanm Socket6
# cpanm Text::Template
# cpanm IO::Socket::INET6
# cpanm Net::INET6Glue
# cpanm Net::HTTP
# #
# cpanm Net::Graphite
# cpanm Log::Log4perl
# cpanm JSON
# cpanm Sys::SigAction

# yes | PAGER=cat /root/vmware-vsphere-cli-distrib/vmware-install.pl default

# sed -i 's/# $ENV{PERL_NET_HTTPS_SSL_SOCKET_CLASS}/$ENV{PERL_NET_HTTPS_SSL_SOCKET_CLASS}/g' /usr/share/perl/*/VMware/VICommon.pm

# export PERL_MM_USE_DEFAULT=1
# cpan -f -i GAAS/libwww-perl-5.837.tar.gz

/bin/cp -rf /tmp/sexigraf-develop/etc/* /etc/
/bin/cp -rf /tmp/sexigraf-develop/usr/* /usr/
/bin/cp -rf /tmp/sexigraf-develop/var/* /var/
/bin/cp -rf /tmp/sexigraf-develop/opt/* /opt/

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

echo "Intialise empty credentials store"
mkdir -p /var/www/.vmware/credstore

cat >/var/www/.vmware/credstore/vicredentials.xml <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<viCredentials>
    <version>1.1</version>
</viCredentials>
EOL

chown -R www-data. /var/www/

chown root:grafana /etc/grafana/provisioning/dashboards/*.yaml

# https://github.com/grafana/grafana/issues/15647
sed -i 's/;disable_sanitize_html = false/disable_sanitize_html = true/g' /etc/grafana/grafana.ini
# customizing grafana
sed -i 's/;reporting_enabled = true/reporting_enabled = false/g' /etc/grafana/grafana.ini
sed -i 's/;check_for_updates = true/check_for_updates = false/g' /etc/grafana/grafana.ini
sed -i 's/;disable_gravatar = false/disable_gravatar = true/g' /etc/grafana/grafana.ini
sed -i 's/;http_addr =/http_addr = 127.0.0.1/g' /etc/grafana/grafana.ini

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
echo "Grafana default configuration completed, switching default password"
curl --noproxy localhost -H "Content-Type: application/json" -X PUT -d '{"oldPassword":"admin","newPassword":"Sex!Gr@f","confirmNew":"Sex!Gr@f"}' http://admin:admin@localhost:3000/api/user/password
sleep 1s
# 

mkdir -p /etc/apache2/ssl

openssl req -newkey rsa:4096 -days 3650 -nodes -x509 \
    -subj "/C=FR/ST=Paris/L=Paris/O=SexiBytes/OU=SexiDevs/CN=sexigraf.sexibyt.es/emailAddress=plot@sexigraf.fr" \
    -keyout /etc/apache2/ssl/sexigraf.key \
    -out /etc/apache2/ssl/sexigraf.crt

a2enmod proxy
a2enmod proxy_http
a2enmod ssl
a2enmod socache_shmcb
a2enmod rewrite

chmod a+x /opt/sexigraf/PullGuestInfo.sh
# chmod a+x /root/ViPullStatistics.pl
# chmod a+x /root/VsanPullStatistics.pl
# chmod a+x /root/getInventory.pl
chmod a+x /opt/sexigraf/*.ps1

echo "Intialise empty PS credentials store"
/usr/bin/pwsh -f /opt/sexigraf/CredstoreAdmin.ps1 -createstore -credstore /mnt/wfs/inventory/vipscredentials.xml
chown www-data:www-data /mnt/wfs/inventory/vipscredentials.xml

mkdir -p /var/log/sexigraf
mkdir -p /var/log/apache2/graphite

# Configure crontab for vmtools infos
echo "\n@reboot         root    /bin/bash /opt/sexigraf/PullGuestInfo.sh" >> /etc/crontab

# echo "Removing unused files"
# rm -f /root/VMware-vSphere-Perl-SDK-*.tar.gz
# rm -rf /root/vmware-vsphere-cli-distrib/
# echo "SexiDone"