# Copyright 2023 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2

<#
    .DESCRIPTION
    Enables Windows Remote Management on Windows builds.
#>

$ErrorActionPreference = 'Stop'

# Disable system hibernation
Write-Host "-- Disabling system hibernation ..."
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power\" -Name "HiberFileSizePercent" -Value 0 | Out-Null
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power\" -Name "HibernateEnabled" -Value 0 | Out-Null

# Disable password expiration for Administrator
Write-Host "-- Disabling password expiration for local Administrator user ..."
Set-LocalUser Administrator -PasswordNeverExpires $true

# # Disable TLS 1.0
# Write-Host "-- Disabling TLS 1.0 ..."
# New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.0" | Out-Null
# New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0" -Name "Server" | Out-Null
# New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0" -Name "Client" | Out-Null
# New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "Enabled" -Value 0 | Out-Null
# New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "DisabledByDefault" -Value 1 | Out-Null
# New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled" -Value 0 | Out-Null
# New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "DisabledByDefault" -Value 1 | Out-Null
 
# # Disable TLS 1.1
# Write-Host "-- Disabling TLS 1.1 ..."
# New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.1" | Out-Null
# New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1" -Name "Server" | Out-Null
# New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1" -Name "Client" | Out-Null
# New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "Enabled" -Value 0 | Out-Null
# New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "DisabledByDefault" -Value 1 | Out-Null
# New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "Enabled" -Value 0 | Out-Null
# New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "DisabledByDefault" -Value 1 | Out-Null

# Set network connections provile to Private mode.
Write-Output 'Setting the network connection profiles to Private...'
$connectionProfile = Get-NetConnectionProfile
While ($connectionProfile.Name -eq 'Identifying...') {
    Start-Sleep -Seconds 10
    $connectionProfile = Get-NetConnectionProfile
}
Set-NetConnectionProfile -Name $connectionProfile.Name -NetworkCategory Private

# Set the Windows Remote Management configuration.
Write-Output 'Setting the Windows Remote Management configuration...'
winrm quickconfig -quiet
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

# Allow Windows Remote Management in the Windows Firewall.
Write-Output 'Allowing Windows Remote Management in the Windows Firewall...'
netsh advfirewall firewall set rule group="Windows Remote Administration" new enable=yes
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=allow

# Reset the autologon count.
# Reference: https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-logoncount#logoncount-known-issue
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0

# Install OpenSSH
Write-Host "-- Installing OpenSSH ..."
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 | Out-Null
Set-Service sshd -StartupType Automatic | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force | Out-Null

# # Installing Cloudbase-Init
# Write-Host "-- Installing Cloudbase-Init ..."
# $msiLocation = 'https://cloudbase.it/downloads'
# $msiFileName = 'CloudbaseInitSetup_Stable_x64.msi'
# Invoke-WebRequest -Uri ($msiLocation + '/' + $msiFileName) -OutFile C:\$msiFileName
# Unblock-File -Path C:\$msiFileName
# Start-Process msiexec.exe -ArgumentList "/i C:\$msiFileName /qn /norestart RUN_SERVICE_AS_LOCAL_SYSTEM=1" -Wait
# Write-Host " - Configuring Cloudbase-Init for VMwareGuestInfoService ..."
# $confFile = 'cloudbase-init.conf'
# $confPath = "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\"
# $confContent = @"
# [DEFAULT]
# bsdtar_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\bsdtar.exe
# mtools_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\
# verbose=true
# debug=true
# logdir=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\
# logfile=cloudbase-init.log
# default_log_levels=comtypes=INFO,suds=INFO,iso8601=WARN,requests=WARN
# local_scripts_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\
# metadata_services=cloudbaseinit.metadata.services.vmwareguestinfoservice.VMwareGuestInfoService
# plugins=cloudbaseinit.plugins.common.userdata.UserDataPlugin
# "@
# New-Item -Path $confPath -Name $confFile -ItemType File -Force -Value $confContent | Out-Null
# Start-Process sc.exe -ArgumentList "config cloudbase-init start= delayed-auto" -wait | Out-Null
# Remove-Item -Path ($confPath + "cloudbase-init-unattend.conf") -Confirm:$false 
# Remove-Item -Path ($confPath + "Unattend.xml") -Confirm:$false 
# Remove-Item C:\$msiFileName -Confirm:$false

# Enabling RDP connections
Write-Host "-- Enabling RDP connections ..."
Start-Process netsh -ArgumentList 'advfirewall firewall set rule group="Remote Desktop" new enable=yes' -wait | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 | Out-Null

Write-Host "-- Configuration complete ..."