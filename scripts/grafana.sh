# Grafana
#
DEBIAN_FRONTEND=noninteractive apt-get install -y adduser libfontconfig1 sqlite3
# 
wget https://dl.grafana.com/oss/release/grafana_6.6.1_amd64.deb
DEBIAN_FRONTEND=noninteractive dpkg -i grafana_6.6.1_amd64.deb
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
echo "Grafana default configuration completed, switching default password"
curl --noproxy localhost -H "Content-Type: application/json" -X PUT -d '{"oldPassword":"admin","newPassword":"Sex!Gr@f","confirmNew":"Sex!Gr@f"}' http://admin:admin@localhost:3000/api/user/password
sleep 1s
# 
echo "Remove anoying gettingstarted plugin banner"
# https://github.com/grafana/grafana/issues/8402
sqlite3 /var/lib/grafana/grafana.db "update user set help_flags1 = 1 where login = 'admin';"