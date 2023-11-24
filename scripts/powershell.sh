# https://docs.microsoft.com/en-us/powershell/scripting/install/install-ubuntu?view=powershell-7.2
wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.16/powershell-lts_7.2.16-1.deb_amd64.deb -O /tmp/powershell.deb
DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/powershell.deb

# Install PowerCLI
# https://vdc-download.vmware.com/vmwb-repository/dcr-public/249b0685-9188-4214-bafe-db9132a8582d/2184c002-1c41-458a-8584-87a461c7da23/powercli1150-compat-matrix.html
/usr/bin/pwsh -Command 'Install-Module -Name VMware.PowerCLI -Scope AllUsers -Force -Confirm:$false'
/usr/bin/pwsh -Command 'Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -ParticipateInCEIP $false -ProxyPolicy noproxy -DisplayDeprecationWarnings $false -DefaultVIServerMode single -Scope AllUsers -Confirm:$false'

# clone Graphite-PowerShell-Functions
git clone https://github.com/sexibytes/Graphite-PowerShell-Functions.git /usr/local/share/powershell/Modules/Graphite-PowerShell-Functions

# Install VMware.Hv.Helper
mkdir -p /usr/local/share/powershell/Modules/VMware.HV.Helper
wget https://raw.githubusercontent.com/vmware/PowerCLI-Example-Scripts/master/Modules/VMware.Hv.Helper/VMware.HV.Helper.psm1 -O /usr/local/share/powershell/Modules/VMware.HV.Helper/VMware.HV.Helper.psm1