# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7
# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb

# Register the Microsoft repository GPG keys
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# Update the list of products
apt-get update

# Install PowerShell
apt-get install -y powershell

# Install PowerCLI
# https://vdc-download.vmware.com/vmwb-repository/dcr-public/249b0685-9188-4214-bafe-db9132a8582d/2184c002-1c41-458a-8584-87a461c7da23/powercli1150-compat-matrix.html
/usr/bin/pwsh -Command 'Install-Module -Name VMware.PowerCLI -Scope AllUsers -Force -Confirm:$false'
/usr/bin/pwsh -Command 'Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -ParticipateInCEIP $false -ProxyPolicy noproxy -DisplayDeprecationWarnings $false -DefaultVIServerMode single -Scope AllUsers -Confirm:$false'

# clone Graphite-PowerShell-Functions
git clone https://github.com/MattHodge/Graphite-PowerShell-Functions.git /usr/local/share/powershell/Modules/Graphite-PowerShell-Functions