# https://graphite.readthedocs.io/en/latest/install-source.html
# https://github.com/graphite-project/graphite-web/issues/2351#issuecomment-420013046
# https://github.com/obfuscurity/synthesize
# https://graphite.readthedocs.io/en/latest/install-pip.html
# 
DEBIAN_FRONTEND=noninteractive apt-get install -y pkg-config fontconfig apache2 libapache2-mod-wsgi-py3 git collectd-core gcc g++ make libtool automake python3-dev python3-pip apache2-bin apache2-data apache2-utils php-cli php-common php-json php-readline php-fpm libapache2-mod-php php-curl python3-cffi php-dom
# 
# rm /usr/lib/python3.*/EXTERNALLY-MANAGED
#
export PYTHONPATH="/opt/graphite/lib/:/opt/graphite/webapp/"
pip install --no-binary=:all: https://github.com/graphite-project/whisper/tarball/master

pip3 install pyparsing setuptools==45.2.0 incremental==22.10.0 django==3.2.25 twisted==24.3.0 python-memcached pymemcache

pip install --no-binary=:all: https://github.com/graphite-project/carbon/tarball/master
pip install --no-binary=:all: https://github.com/graphite-project/graphite-web/tarball/master
# 
cp /opt/graphite/webapp/graphite/local_settings.py.example /opt/graphite/webapp/graphite/local_settings.py
sed -i -e "s/UNSAFE_DEFAULT/`date | md5sum | cut -d ' ' -f 1`/" /opt/graphite/webapp/graphite/local_settings.py
sed -i -e "s/#SECRET_KEY/SECRET_KEY/g" /opt/graphite/webapp/graphite/local_settings.py
# 
# https://carminebufano.com/index.php/2024/11/02/how-to-fix-openstack-horizon-dashboard-on-centos-stream-9-error-invalidcachebackenderror/
sed -i -e "s/django\.core\.cache\.backends\.memcached\.MemcachedCache/django\.core\.cache\.backend\s.memcached\.PyMemcacheCache/g" /opt/graphite/webapp/graphite/settings.py
#
cp /opt/graphite/examples/example-graphite-vhost.conf /etc/apache2/sites-available/graphite.conf
cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/conf/graphite.wsgi
# 
mkdir /etc/apache2/run
# 
a2dissite 000-default
a2ensite graphite
a2enmod headers
service apache2 restart
#
sleep 10s
# 
PYTHONPATH=/opt/graphite/webapp django-admin migrate --settings=graphite.settings # --run-syncdb
PYTHONPATH=/opt/graphite/webapp django-admin collectstatic --noinput --settings=graphite.settings
# 
groupadd -g 998 carbon
useradd -c "carbon user" -g 998 -u 998 -s /bin/false carbon
chmod 775 /opt/graphite/storage
chown www-data:carbon /opt/graphite/storage
chown www-data:www-data /opt/graphite/storage/graphite.db
chown -R carbon /opt/graphite/storage/whisper
# mkdir /opt/graphite/storage/log/apache2
chown -R www-data /opt/graphite/storage/log/webapp
cp /opt/graphite/examples/init.d/carbon-cache /etc/init.d/carbon-cache
chmod +x /etc/init.d/carbon-cache
# 
cp /opt/graphite/bin/build-index /etc/cron.hourly/graphite-build-index
chmod 755 /etc/cron.hourly/graphite-build-index
sudo -u www-data /opt/graphite/bin/build-index.sh
# 
cp /opt/graphite/conf/carbon.conf.example /opt/graphite/conf/carbon.conf
# sed -i -e "s/ENABLE_UDP_LISTENER = False/ENABLE_UDP_LISTENER = True/g" /opt/graphite/conf/carbon.conf
sed -i -e "s/MAX_UPDATES_PER_SECOND = 500/MAX_UPDATES_PER_SECOND = inf/g" /opt/graphite/conf/carbon.conf
sed -i -e "s/MAX_CREATES_PER_MINUTE = 50/MAX_CREATES_PER_MINUTE = inf/g" /opt/graphite/conf/carbon.conf
sed -i -e "s/# GRAPHITE_URL = http\:\/\/127\.0\.0\.1\:80/GRAPHITE_URL = http\:\/\/127\.0\.0\.1\:8080/g" /opt/graphite/conf/carbon.conf
sed -i -e "s/ENABLE_LOGROTATION = True/ENABLE_LOGROTATION = False\nLOG_DIR = \/var\/log\/sexigraf\//g" /opt/graphite/conf/carbon.conf
sed -i -e "s/# LOG_LISTENER_CONN_SUCCESS = True/LOG_LISTENER_CONN_SUCCESS = False/g" /opt/graphite/conf/carbon.conf
# https://github.com/graphite-project/carbon/issues/816
sed -i -e "s/# ENABLE_TAGS = True/ENABLE_TAGS = False/g" /opt/graphite/conf/carbon.conf
# sed -i -e "s/CACHE_WRITE_STRATEGY = sorted/CACHE_WRITE_STRATEGY = max/g" /opt/graphite/conf/carbon.conf
mkdir -p /var/log/sexigraf
# 
cp /opt/graphite/conf/graphTemplates.conf.example /opt/graphite/conf/graphTemplates.conf
cp /opt/graphite/conf/storage-aggregation.conf.example /opt/graphite/conf/storage-aggregation.conf
cp /opt/graphite/conf/storage-schemas.conf.example /opt/graphite/conf/storage-schemas.conf
# 
# https://wiki.debian.org/LSBInitScripts
sed -i '/^#!\/bin\/bash/a ### BEGIN INIT INFO\n# Provides:          carbon-cache\n# Required-Start:    $remote_fs $syslog\n# Required-Stop:     $remote_fs $syslog\n# Default-Start:     2 3 4 5\n# Default-Stop:      0 1 6\n# Short-Description: Start carbon-cache at boot time\n# Description:       Enable service provided by carbon-cache\n### END INIT INFO' /etc/init.d/carbon-cache
# 
sed -i '/^function die {/i echo_success() {\necho -n "OK"\nreturn 0\n}\n\necho_failure() {\necho -n "FAILED"\nreturn 1\n}\n' /etc/init.d/carbon-cache
#
sed -i '/Alias \/static\/ \/opt\/graphite\/static\//a\        <Directory \/opt\/graphite\/static\/>\n                Require all granted\n        <\/Directory>\n \n' /etc/apache2/sites-available/graphite.conf
# 
update-rc.d carbon-cache defaults
service carbon-cache start
systemctl restart apache2
# 
echo "export PYTHONPATH=/opt/graphite/webapp" >> /root/.bashrc