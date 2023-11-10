packer {
  required_version = ">= 1.9.4"
  required_plugins {
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = ">= 1.2.1"
    }
    windows-update = {
      source  = "github.com/rgl/windows-update"
      version = ">= 0.14.3"
    }
  }
}

// //  BLOCK: data
// //  Defines the data sources.

// data "git-repository" "cwd" {}

//  BLOCK: locals
//  Defines the local variables.

locals {
  script_files               = ["${path.root}/setup/setup.ps1"]
  build_by                   = "Built by: HashiCorp Packer ${packer.version}"
  build_date                 = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  build_version              = formatdate("YYYY-MM", timestamp())
  build_description          = "VER: ${ local.build_version }\nDATE: ${ local.build_date }\nISO: ${ var.os_iso_file }\nUSERNAME: ${ var.build_username }\nPASSWORD: ${ var.build_password }"
  iso_paths                  = ["[${ var.os_iso_datastore }] ${ var.os_iso_path }/${ var.os_iso_file }", "[] /vmimages/tools-isoimages/${var.vm_guest_os_family}.iso"]
  // manifest_date              = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  // manifest_path              = "${path.cwd}/manifests/"
  // manifest_output            = "${local.manifest_path}${local.manifest_date}.json"
  // ovf_export_path            = "${path.cwd}/artifacts/"
  vm_name_datacenter_core    = "${var.vm_guest_os_family}-${var.vm_guest_os_name}-${var.vm_guest_os_version}-${var.vm_guest_os_edition_datacenter}-${var.vm_guest_os_experience_core}-${local.build_version}"
  vm_name_datacenter_desktop = "${var.vm_guest_os_family}-${var.vm_guest_os_name}-${var.vm_guest_os_version}-${var.vm_guest_os_edition_datacenter}-${var.vm_guest_os_experience_desktop}-${local.build_version}"
  vm_name_standard_core      = "${var.vm_guest_os_family}-${var.vm_guest_os_name}-${var.vm_guest_os_version}-${var.vm_guest_os_edition_standard}-${var.vm_guest_os_experience_core}-${local.build_version}"
  vm_name_standard_desktop   = "${var.vm_guest_os_family}-${var.vm_guest_os_name}-${var.vm_guest_os_version}-${var.vm_guest_os_edition_standard}-${var.vm_guest_os_experience_desktop}-${local.build_version}"
  // bucket_name                = replace("${var.vm_guest_os_family}-${var.vm_guest_os_name}-${var.vm_guest_os_version}", ".", "")
  // bucket_description         = "${var.vm_guest_os_family} ${var.vm_guest_os_name} ${var.vm_guest_os_version}"
}

//  BLOCK: source
//  Defines the builder configuration blocks.

source "vsphere-iso" "windows-server-standard-core" {

  // vCenter Server Endpoint Settings and Credentials
  vcenter_server      = var.vcenter_server
  username            = var.vcenter_username
  password            = var.vcenter_password
  insecure_connection = var.vsphere_insecure_connection

  // vSphere Settings
  cluster    = var.vcenter_cluster
  datastore  = var.vcenter_datastore
  folder     = var.vcenter_folder

  # Content Library and Template Settings
  convert_to_template         = var.vcenter_convert_template
  create_snapshot             = var.vcenter_snapshot
  snapshot_name               = var.vcenter_snapshot_name
  content_library_destination {
      library                 = var.vcenter_content_library
      name                    = local.vm_name_standard_core
      description             = local.vm_description
      ovf                     = var.vcenter_content_library_ovf
      destroy                 = var.vcenter_content_library_destroy
      skip_import             = var.vcenter_content_library_skip
  }

  // Virtual Machine Settings
  vm_name              = local.vm_name_standard_core
  notes                = local.build_description
  guest_os_type        = var.vm_guest_os_type
  firmware             = var.vm_firmware
  CPUs                 = var.vm_cpu_count
  cpu_cores            = var.vm_cpu_cores
  CPU_hot_plug         = var.vm_cpu_hot_add
  RAM                  = var.vm_mem_size
  RAM_hot_plug         = var.vm_mem_hot_add
  cdrom_type           = var.vm_cdrom_type
  remove_cdrom         = var.common_remove_cdrom
  disk_controller_type = var.vm_disk_controller_type
  storage {
    disk_size             = var.vm_disk_size
    disk_thin_provisioned = var.vm_disk_thin_provisioned
  }
  network_adapters {
    network      = var.vcenter_network
    network_card = var.vm_network_card
  }
  
  // Removable Media Settings
  iso_paths = local.iso_paths
  cd_files = [
    "${path.root}/setup/"
  ]
  cd_content = {
    "autounattend.xml" = templatefile("${abspath(path.root)}/setup/autounattend.pkrtpl.hcl", {
      build_username       = var.build_username
      build_password       = var.build_password
      vm_inst_os_language  = var.vm_inst_os_language
      vm_inst_os_keyboard  = var.vm_inst_os_keyboard
      vm_inst_os_image     = var.vm_inst_os_image_standard_core
      vm_inst_os_kms_key   = var.vm_inst_os_kms_key_standard
      vm_guest_os_language = var.vm_guest_os_language
      vm_guest_os_keyboard = var.vm_guest_os_keyboard
      vm_guest_os_timezone = var.vm_guest_os_timezone
    })
  }

  // Boot and Provisioning Settings
  boot_order       = var.vm_boot_order
  boot_wait        = var.vm_boot_wait
  boot_command     = var.vm_boot_command
  ip_wait_timeout  = var.common_ip_wait_timeout
  shutdown_command = var.vm_shutdown_command
  shutdown_timeout = var.common_shutdown_timeout

  // Communicator Settings and Credentials
  communicator   = "winrm"
  winrm_username = var.build_username
  winrm_password = var.build_password
  winrm_port     = var.communicator_port
  winrm_timeout  = var.communicator_timeout

}

source "vsphere-iso" "windows-server-standard-dexp" {

  // vCenter Server Endpoint Settings and Credentials
  vcenter_server      = var.vcenter_server
  username            = var.vcenter_username
  password            = var.vcenter_password
  insecure_connection = var.vsphere_insecure_connection

  // vSphere Settings
  cluster    = var.vcenter_cluster
  datastore  = var.vcenter_datastore
  folder     = var.vcenter_folder

  # Content Library and Template Settings
  convert_to_template         = var.vcenter_convert_template
  create_snapshot             = var.vcenter_snapshot
  snapshot_name               = var.vcenter_snapshot_name
  content_library_destination {
      library                 = var.vcenter_content_library
      name                    = local.vm_name_standard_desktop
      description             = local.vm_description
      ovf                     = var.vcenter_content_library_ovf
      destroy                 = var.vcenter_content_library_destroy
      skip_import             = var.vcenter_content_library_skip
  }

  // Virtual Machine Settings
  vm_name              = local.vm_name_standard_desktop
  notes                = local.build_description
  guest_os_type        = var.vm_guest_os_type
  firmware             = var.vm_firmware
  CPUs                 = var.vm_cpu_count
  cpu_cores            = var.vm_cpu_cores
  CPU_hot_plug         = var.vm_cpu_hot_add
  RAM                  = var.vm_mem_size
  RAM_hot_plug         = var.vm_mem_hot_add
  cdrom_type           = var.vm_cdrom_type
  remove_cdrom         = var.common_remove_cdrom
  disk_controller_type = var.vm_disk_controller_type
  storage {
    disk_size             = var.vm_disk_size
    disk_controller_index = 0
    disk_thin_provisioned = var.vm_disk_thin_provisioned
  }
  network_adapters {
    network      = var.vcenter_network
    network_card = var.vm_network_card
  }

  // Removable Media Settings
  iso_paths = local.iso_paths
  cd_files = [
    "${path.root}/setup/"
  ]
  cd_content = {
    "autounattend.xml" = templatefile("${abspath(path.root)}/setup/autounattend.pkrtpl.hcl", {
      build_username       = var.build_username
      build_password       = var.build_password
      vm_inst_os_language  = var.vm_inst_os_language
      vm_inst_os_keyboard  = var.vm_inst_os_keyboard
      vm_inst_os_image     = var.vm_inst_os_image_standard_desktop
      vm_inst_os_kms_key   = var.vm_inst_os_kms_key_standard
      vm_guest_os_language = var.vm_guest_os_language
      vm_guest_os_keyboard = var.vm_guest_os_keyboard
      vm_guest_os_timezone = var.vm_guest_os_timezone
    })
  }

  // Boot and Provisioning Settings
  boot_order       = var.vm_boot_order
  boot_wait        = var.vm_boot_wait
  boot_command     = var.vm_boot_command
  ip_wait_timeout  = var.common_ip_wait_timeout
  shutdown_command = var.vm_shutdown_command
  shutdown_timeout = var.common_shutdown_timeout

  // Communicator Settings and Credentials
  communicator   = "winrm"
  winrm_username = var.build_username
  winrm_password = var.build_password
  winrm_port     = var.communicator_port
  winrm_timeout  = var.communicator_timeout

}


//  BLOCK: build
//  Defines the builders to run, provisioners, and post-processors.

build {
  sources = [
    "source.vsphere-iso.windows-server-standard-core",
    "source.vsphere-iso.windows-server-standard-dexp"
  ]

  provisioner "powershell" {
    environment_vars = [
      "BUILD_USERNAME=${var.build_username}"
    ]
    elevated_user     = var.build_username
    elevated_password = var.build_password
    scripts           = local.script_files
  }

  provisioner "powershell" {
    elevated_user     = var.build_username
    elevated_password = var.build_password
    inline            = var.inline
  }

  provisioner "windows-update" {
    pause_before    = "30s"
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*VMware*'",
      "exclude:$_.Title -like '*Preview*'",
      "exclude:$_.Title -like '*Defender*'",
      "exclude:$_.InstallationBehavior.CanRequestUserInput",
      "include:$true"
    ]
    restart_timeout = "120m"
  }

  post-processor "manifest" {
    output     = local.manifest_output
    strip_path = true
    strip_time = true
    custom_data = {
      build_username           = var.build_username
      build_date               = local.build_date
      build_version            = local.build_version
      vm_cpu_cores             = var.vm_cpu_cores
      vm_cpu_count             = var.vm_cpu_count
      vm_disk_size             = var.vm_disk_size
      vm_disk_thin_provisioned = var.vm_disk_thin_provisioned
      vm_firmware              = var.vm_firmware
      vm_guest_os_type         = var.vm_guest_os_type
      vm_mem_size              = var.vm_mem_size
      vm_network               = var.vcenter_network
      vsphere_cluster          = var.vcenter_cluster
      vsphere_datastore        = var.vcenter_datastore
      vsphere_endpoint         = var.vcenter_server
      vsphere_folder           = var.vcenter_folder
    }
  }

}