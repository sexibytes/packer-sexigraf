# Grafana
#
DEBIAN_FRONTEND=noninteractive apt-get install -y adduser libfontconfig1 sqlite3 libxss1 libasound2
#
cd /root
wget https://dl.grafana.com/oss/release/grafana_7.5.11_amd64.deb -O /tmp/grafana.deb
DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/grafana.deb
# 
systemctl daemon-reload
systemctl enable grafana-server.service
systemctl start grafana-server
sleep 5s
# 
echo "Update grafana conf before updating password (easier curl calls)"
curl --noproxy localhost -H "Content-Type: application/json" -X POST -d '{"name":"local","type":"graphite","url":"http://127.0.0.1:8080","access":"proxy","isDefault":true,"basicAuth":false}' http://admin:admin@localhost:3000/api/datasources
sleep 1s
# 
curl --noproxy localhost -H "Content-Type: application/json" -X PUT -d '{"theme": "light"}' http://admin:admin@localhost:3000/api/user/preferences
sleep 1s
# 
echo "Remove anoying gettingstarted plugin banner"
# https://github.com/grafana/grafana/issues/8402
sqlite3 /var/lib/grafana/grafana.db "update user set help_flags1 = 1 where login = 'admin';"
#
# https://github.com/grafana/grafana/issues/16495
# https://github.com/grafana/grafana-image-renderer
grafana-cli plugins install grafana-image-renderer
#
# https://marcus.se.net/grafana-csv-datasource/
grafana-cli plugins install marcusolsson-csv-datasource