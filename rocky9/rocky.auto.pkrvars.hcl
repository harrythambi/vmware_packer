# ISO Settings
os_iso_file                     = "Rocky-9.4-x86_64-dvd.iso"
os_iso_path                     = "ISOs"

# OS Meta Data
vm_os_family                    = "Linux"
vm_os_type                      = "Server"
vm_os_vendor                    = "Rocky"
vm_os_version                   = "9.4"

# VM Hardware Settings
vm_firmware                     = "efi-secure"
vm_cpu_sockets                  = 2
vm_cpu_cores                    = 1
vm_mem_size                     = 2048
vm_nic_type                     = "vmxnet3"
vm_disk_controller              = ["pvscsi"]
vm_disk_size                    = 32768
vm_disk_thin                    = true
vm_cdrom_type                   = "sata"

# VM Settings
vm_cdrom_remove                 = true
vcenter_convert_template        = false
vcenter_content_library_ovf     = true
vcenter_content_library_destroy = true

# VM OS Settings
vm_guestos_type                 = "rhel9_64Guest"
vm_guestos_language             = "en_GB"
vm_guestos_keyboard             = "gb"
vm_guestos_timezone             = "UTC"

# Provisioner Settings
script_files                    = [ "setup/setup.sh" ]
inline_cmds                     = []