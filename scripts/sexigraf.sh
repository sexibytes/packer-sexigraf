# Create empty folder for logs
mkdir /var/log/sexigraf/

# install Graphite requisites (forcing unattend as graphite-carbon request default interactive) and others stuff in unstable branch to get version 1.0+
# echo "deb http://http.us.debian.org/debian sid main contrib non-free" >> /etc/apt/sources.list
apt-get update -y
# DEBIAN_FRONTEND=noninteractive apt-get -y -t unstable --no-install-recommends install graphite-carbon graphite-web collectd
DEBIAN_FRONTEND=noninteractive apt-get -y --allow-downgrades --allow-remove-essential --allow-change-held-packages --no-install-recommends install libhtml-template-perl libnumber-bytes-human-perl xml-twig-tools libsnmp30 cpanminus genisoimage collectd

/bin/cp -rf /tmp/sexigraf-dev6/root/* /root/
tar -zxf /root/VMware-vSphere-Perl-SDK-6.7.0-8156551.x86_64.tar.gz -C /root/

cpanm ExtUtils::MakeMaker@6.96
cpanm Net::FTP@2.77
cpanm UUID::Random@0.04
cpanm UUID
cpanm Net::Graphite@0.16
cpanm Module::Build@0.4205 --force
cpanm Text::Template@1.47

cd /root/cpan-packages/
for i in /root/cpan-packages/*.tar.gz; do tar -xvzf $i; done

# Theses packages are not available through deb files, compilation is required
cd /root/cpan-packages/libwww-perl-5.837; perl Makefile.PL; make; make install

# Remove uneccessary packages used for compliation
# apt-get -y purge gcc-4.9-base:i386
# dpkg --remove-architecture i386

sed -i 's/ubuntu/debian/g' /root/vmware-vsphere-cli-distrib/vmware-install.pl
yes | PAGER=cat /root/vmware-vsphere-cli-distrib/vmware-install.pl default

/bin/cp -rf /tmp/sexigraf-dev6/etc/* /etc/
/bin/cp -rf /tmp/sexigraf-dev6/usr/* /usr/
/bin/cp -rf /tmp/sexigraf-dev6/var/* /var/
/bin/cp -rf /tmp/sexigraf-dev6/opt/* /opt/

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

chown chown root:grafana /etc/grafana/provisioning/dashboards/*.yaml

# https://github.com/grafana/grafana/issues/15647
sed -i 's/;disable_sanitize_html = false/disable_sanitize_html = true/g' /etc/grafana/grafana.ini

a2enmod proxy
a2enmod proxy_http
a2enmod ssl

chmod a+x /root/PullGuestInfo.sh
chmod a+x /root/ViPullStatistics.pl
chmod a+x /root/VsanPullStatistics.pl
chmod a+x /root/getInventory.pl
chmod a+x /root/seximenu/seximenu.sh
mkdir -p /var/log/sexigraf

# Configure crontab for vmtools infos
echo "\n@reboot         root    /bin/bash /root/PullGuestInfo.sh" >> /etc/crontab

echo "Removing unused files"
rm -f /root/VMware-vSphere-Perl-SDK-6.7.0-8156551.x86_64.tar.gz
rm -rf /root/vmware-vsphere-cli-distrib/
rm -rf /root/cpan-packages/
rm -f /root/sexiauditor.patch
rm -f /root/VICommon.pm
echo "SexiDone"
