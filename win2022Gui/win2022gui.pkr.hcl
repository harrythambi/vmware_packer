packer {
  required_version = ">= 1.9.4"
  required_plugins {
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = ">= 1.2.1"
    }
  }
}

locals { 
    build_version       = formatdate("YY.MM", timestamp())
    build_date          = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
    iso_paths           = ["[${ var.os_iso_datastore }] ${ var.os_iso_path }/${ var.os_iso_file }"]
    script_files        = ["${path.root}/setup/setup.sh"]
    ks_content          = {
                            "ks.cfg" = templatefile("${abspath(path.root)}/setup/ks.pkrtpl.hcl", {
                                build_username            = var.build_username
                                build_password            = var.build_password
                                vm_guestos_language       = var.vm_guestos_language
                                vm_guestos_keyboard       = var.vm_guestos_keyboard
                                vm_guestos_timezone       = var.vm_guestos_timezone
                            })
                          }
    vm_description      = "VER: ${ local.build_version }\nDATE: ${ local.build_date }\nISO: ${ var.os_iso_file }\nUSERNAME: ${ var.build_username }\nPASSWORD: ${ var.build_password }"
}

source "vsphere-iso" "rocky" {
    # vCenter
    vcenter_server              = var.vcenter_server
    username                    = var.vcenter_username
    password                    = var.vcenter_password
    insecure_connection         = var.vcenter_insecure
    cluster                     = var.vcenter_cluster
    folder                      = var.vcenter_folder
    datastore                   = var.vcenter_datastore

    # Content Library and Template Settings
    convert_to_template         = var.vcenter_convert_template
    create_snapshot             = var.vcenter_snapshot
    snapshot_name               = var.vcenter_snapshot_name
    content_library_destination {
        library                 = var.vcenter_content_library
        name                    = "${ var.template_name }-${ local.build_version }"
        description             = local.vm_description
        ovf                     = var.vcenter_content_library_ovf
        destroy                 = var.vcenter_content_library_destroy
        skip_import             = var.vcenter_content_library_skip
    }

    # Virtual Machine
    guest_os_type               = var.vm_guestos_type
    vm_name                     = "${ source.name }-${ local.build_version }"
    notes                       = local.vm_description
    firmware                    = var.vm_firmware
    CPUs                        = var.vm_cpu_sockets
    cpu_cores                   = var.vm_cpu_cores
    CPU_hot_plug                = var.vm_cpu_hotadd
    RAM                         = var.vm_mem_size
    RAM_hot_plug                = var.vm_mem_hotadd
    cdrom_type                  = var.vm_cdrom_type
    remove_cdrom                = var.vm_cdrom_remove
    disk_controller_type        = var.vm_disk_controller
    storage {
        disk_size               = var.vm_disk_size
        disk_thin_provisioned   = var.vm_disk_thin
    }
    network_adapters {
        network                 = var.vcenter_network
        network_card            = var.vm_nic_type
    }

    # Removeable Media
    iso_paths                   = ["[${ var.os_iso_datastore }] ${ var.os_iso_path }/${ var.os_iso_file }"]
    cd_content                  = local.ks_content

    # Boot and Provisioner
    boot_order                  = var.vm_boot_order
    boot_wait                   = var.vm_boot_wait
    boot_command                = [ "up", "wait", "e", "<down><down><end><wait>",
                                    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
                                    "quiet text inst.ks=cdrom",
                                    "<enter><wait><leftCtrlOn>x<leftCtrlOff>" ]
    ip_wait_timeout             = var.vm_ip_timeout
    communicator                = "ssh"
    ssh_username                = var.build_username
    ssh_password                = var.build_password
    shutdown_command            = "sudo shutdown -P now"
    shutdown_timeout            = var.vm_shutdown_timeout
}

build {
    name                        = var.template_name
    sources                     = ["source.vsphere-iso.rocky"]

    provisioner "shell" {
        execute_command         = "echo '${ var.build_password }' | {{ .Vars }} sudo -E -S sh -eu '{{.Path}}'"
        scripts                 = local.scripts_folder
    }
}