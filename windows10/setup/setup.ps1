$ErrorActionPreference = "Stop"
 
# Switch network connection to private mode
# Required for WinRM firewall rules
$profile = Get-NetConnectionProfile
Set-NetConnectionProfile -Name $profile.Name -NetworkCategory Private
 
# Enable WinRM service
winrm quickconfig -quiet
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
 
# Reset auto logon count
# https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-logoncount#logoncount-known-issue
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0


# dism /online /quiet /set-edition:{{win_edition}} /productkey:WX4NM-KYWYW-QJJR4-XV3QB-6VM33 /accepteula

# https://packages.vmware.com/tools/esx/7.0u3/windows/x64/VMware-tools-11.3.0-18090558-x86_64.exe
# https://packages.vmware.com/tools/releases/11.3.0/windows/VMware-tools-windows-11.3.0-18090558.iso
# $packagesVMWareURLList = "http://packages.vmware.com/tools/esx/7.0u3/windows/x64"
# $latestVMwareTools = ((curl $packagesVMWareURL).links[1].href).split("/")[1]
# $latestVMwareToolsURL = $packagesVMWareURL+"/"+$latestVMwareTools
# Invoke-WebRequest -Uri $latestVMwareToolsURL -OutFile "C:\Windows\temp\vmware-tools.exe"
# C:\Windows\temp\C:\Windows\temp\vmware-tools.exee /S /v"/qn REBOOT=R"
