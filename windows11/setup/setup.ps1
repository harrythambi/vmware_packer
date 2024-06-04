$ErrorActionPreference = "Stop"

# Switch network connection to private mode
# Required for WinRM firewall rules
$profile = Get-NetConnectionProfile
While ($profile.Name -eq "Identifying..."){
    Start-Sleep -Seconds 10
    $profile = Get-NetConnectionProfile
}
Set-NetConnectionProfile -Name $profile.Name -NetworkCategory Private

# Drop the firewall while building and re-enable as a standalone provisioner in the Packer file if needs be
netsh Advfirewall set allprofiles state off

# Enable WinRM service
winrm quickconfig -quiet
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

# Disable IPV6
Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6

# Reset auto logon count
# https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-logoncount#logoncount-known-issue
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0

# Enabling RDP connections
Write-Host "-- Enabling RDP connections ..."
Start-Process netsh -ArgumentList 'advfirewall firewall set rule group="Remote Desktop" new enable=yes' -wait | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 | Out-Null

Write-Host "-- Configuration complete ..."