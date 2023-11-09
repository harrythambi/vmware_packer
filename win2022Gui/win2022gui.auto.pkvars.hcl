# ISO Settings
os_iso_file                     = "win_server_2022_eval.iso"
os_iso_path                     = "ISOs"

# OS Meta Data
vm_os_family                    = "Windows"
vm_os_type                      = "Server"
vm_os_vendor                    = "Microsoft"
vm_os_version                   = "2022"

# VM Hardware Settings
vm_firmware                     = "efi-secure"
vm_cpu_sockets                  = 2
vm_cpu_cores                    = 1
vm_mem_size                     = 2048
vm_nic_type                     = "vmxnet3"
vm_disk_controller              = ["pvscsi"]
vm_disk_size                    = 51200
vm_disk_thin                    = true
vm_cdrom_type                   = "sata"

# VM Settings
vm_cdrom_remove                 = true
vcenter_convert_template        = false
vcenter_content_library_ovf     = true
vcenter_content_library_destroy = true

# VM OS Settings
vm_guestos_type                 = "windows2019srvNext_64Guest"
vm_guestos_language             = "en_GB"
vm_guestos_keyboard             = "en_GB"
vm_guestos_systemlocale         = "en_US"
vm_guestos_timezone             = "GMT Standard Time"

# Provisioner Settings
script_files                    = [ "setup/setup.sh" ]
inline_cmds                     = []