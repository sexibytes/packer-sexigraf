# https://graphite.readthedocs.io/en/latest/install-source.html
# https://github.com/graphite-project/graphite-web/issues/2351#issuecomment-420013046
# https://github.com/obfuscurity/synthesize
# 
DEBIAN_FRONTEND=noninteractive apt-get install -y libcairo2-dev libffi-dev pkg-config python-dev python-pip fontconfig apache2 libapache2-mod-wsgi-py3 git-core collectd gcc g++ make libtool automake python3-dev python3-pip apache2-bin apache2-data apache2-utils php7.3-cli php7.3-common php7.3-json php7.3-readline php7.3-fpm libapache2-mod-php7.3 php7.3-curl
#
cd /usr/local/src
echo "git clone graphite"
git clone https://github.com/graphite-project/graphite-web.git
git clone https://github.com/graphite-project/carbon.git
git clone https://github.com/graphite-project/whisper.git
#
echo "install graphite & co"
cd whisper; python3 setup.py install
cd ../carbon; pip3 install -r requirements.txt; python3 setup.py install
cd ../graphite-web; pip3 install -r requirements.txt; python3 check-dependencies.py; python3 setup.py install
#
cp /opt/graphite/webapp/graphite/local_settings.py.example /opt/graphite/webapp/graphite/local_settings.py
sed -i -e "s/UNSAFE_DEFAULT/`date | md5sum | cut -d ' ' -f 1`/" /opt/graphite/webapp/graphite/local_settings.py
sed -i -e "s/#SECRET_KEY/SECRET_KEY/g" /opt/graphite/webapp/graphite/local_settings.py
#
cp /opt/graphite/examples/example-graphite-vhost.conf /etc/apache2/sites-available/graphite.conf
cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/conf/graphite.wsgi
# 
mkdir /etc/apache2/run
# 
a2dissite 000-default
a2ensite graphite
#
PYTHONPATH=/opt/graphite/webapp django-admin.py migrate --settings=graphite.settings # --run-syncdb
PYTHONPATH=/opt/graphite/webapp django-admin.py collectstatic --noinput --settings=graphite.settings
# 
groupadd -g 998 carbon
useradd -c "carbon user" -g 998 -u 998 -s /bin/false carbon
chmod 775 /opt/graphite/storage
chown www-data:carbon /opt/graphite/storage
chown www-data:www-data /opt/graphite/storage/graphite.db
chown -R carbon /opt/graphite/storage/whisper
# mkdir /opt/graphite/storage/log/apache2
chown -R www-data /opt/graphite/storage/log/webapp
cp /usr/local/src/carbon/distro/debian/init.d/carbon-cache /etc/init.d/carbon-cache
chmod +x /etc/init.d/carbon-cache
# 
cp /opt/graphite/bin/build-index /etc/cron.hourly/graphite-build-index
chmod 755 /etc/cron.hourly/graphite-build-index
sudo -u www-data /opt/graphite/bin/build-index.sh
# 
cp /opt/graphite/conf/carbon.conf.example /opt/graphite/conf/carbon.conf
cp /opt/graphite/conf/graphTemplates.conf.example /opt/graphite/conf/graphTemplates.conf
cp /opt/graphite/conf/storage-aggregation.conf.example /opt/graphite/conf/storage-aggregation.conf
cp /opt/graphite/conf/storage-schemas.conf.example /opt/graphite/conf/storage-schemas.conf
# 
# https://wiki.debian.org/LSBInitScripts
sed -i '/^#!\/bin\/bash/a ### BEGIN INIT INFO\n# Provides:          carbon-cache\n# Required-Start:    $remote_fs $syslog\n# Required-Stop:     $remote_fs $syslog\n# Default-Start:     2 3 4 5\n# Default-Stop:      0 1 6\n# Short-Description: Start carbon-cache at boot time\n# Description:       Enable service provided by carbon-cache\n### END INIT INFO' /etc/init.d/carbon-cache
# 
sed -i '/Alias \/static\/ \/opt\/graphite\/static\//a\        <Directory \/opt\/graphite\/static\/>\n                Require all granted\n        <\/Directory>\n \n' /etc/apache2/sites-available/graphite.conf
# 
update-rc.d carbon-cache defaults
service carbon-cache start
systemctl restart apache2
# 