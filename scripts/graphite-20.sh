# https://graphite.readthedocs.io/en/latest/install-source.html
# https://github.com/graphite-project/graphite-web/issues/2351#issuecomment-420013046
# https://github.com/obfuscurity/synthesize
# 
DEBIAN_FRONTEND=noninteractive apt-get install -y pkg-config fontconfig apache2 libapache2-mod-wsgi-py3 git collectd-core gcc g++ make libtool automake python3-dev python3-pip apache2-bin apache2-data apache2-utils php-cli php-common php-json php-readline php-fpm libapache2-mod-php php-curl python3-cffi
# 
# apt install software-properties-common -y
# add-apt-repository ppa:deadsnakes/ppa -y
# apt-get update
# apt install python3.9 python3-pip python3.9-dev -y
# pip3 install pip --upgrade
# update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1
# update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2
# 
cd /usr/local/src
echo "git clone graphite"
git clone https://github.com/graphite-project/graphite-web.git -b 1.1.x
git clone https://github.com/graphite-project/carbon.git -b 1.1.x
git clone https://github.com/graphite-project/whisper.git -b 1.1.x
# 
echo "install graphite & co"
# pip3 install -Iv pip==20.3.4 --upgrade
pip3 install -v pyparsing==2.4.7 --force-reinstall # https://github.com/graphite-project/graphite-web/issues/2726
pip3 install setuptools # --upgrade
cd whisper; python3 setup.py install
# 
cd ../carbon; pip3 install -r requirements.txt; python3 setup.py install
# https://github.com/obfuscurity/synthesize/blob/master/install
# cd ../graphite-web; pip3 install django==2.2.9; pip3 install -r requirements.txt; python3 check-dependencies.py; python3 setup.py install
cd ../graphite-web; pip3 install django; pip3 install -r requirements.txt; python3 check-dependencies.py; python3 setup.py install
# also install service_identity to remove TLS error
pip3 install txamqp service_identity # --upgrade
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
a2enmod headers
service apache2 restart
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
sed -i '/Alias \/static\/ \/opt\/graphite\/static\//a\        <Directory \/opt\/graphite\/static\/>\n                Require all granted\n        <\/Directory>\n \n' /etc/apache2/sites-available/graphite.conf
# 
update-rc.d carbon-cache defaults
service carbon-cache start
systemctl restart apache2
# 
echo "export PYTHONPATH=/opt/graphite/webapp" >> /root/.bashrc