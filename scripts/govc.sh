# https://www.virtuallyghetto.com/2021/01/record-and-replay-vsphere-inventory-using-govc-and-vcsim.html
wget https://go.dev/dl/go1.23.5.linux-amd64.tar.gz -O /tmp/go.linux-amd64.tar.gz
tar -xf /tmp/go.linux-amd64.tar.gz -C /tmp/
mv /tmp/go /usr/local/
#
echo "#" >> /root/.bashrc
echo "export GOROOT=/usr/local/go" >> /root/.bashrc
echo "export GOPATH=$HOME/go" >> /root/.bashrc
echo "export PATH=$GOPATH/bin:$GOROOT/bin:$PATH" >> /root/.bashrc
#
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
#
curl -L -o - "https://github.com/vmware/govmomi/releases/latest/download/govc_$(uname -s)_$(uname -m).tar.gz" | tar -C /usr/local/bin -xvzf - govc
curl -L -o - https://github.com/vmware/govmomi/releases/latest/download/vcsim_$(uname -s)_$(uname -m).tar.gz | tar -C /usr/local/bin -xvzf - vcsim