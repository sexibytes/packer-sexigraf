source "vsphere-iso" "sexigraf" {
  CPUs                 = 4
  RAM                  = 16384
  boot_command         = ["<esc><esc><esc><esc>e<wait>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\"<enter><wait>", "initrd /casper/initrd<enter><wait>", "boot<enter>", "<enter><f10><wait>"]
  boot_wait            = "3s"
  cluster              = "${var.cluster}"
  host				         = "${var.vsphere_host}"
  convert_to_template  = false
  datastore            = "${var.vsphere_datastore}"
  disk_controller_type = "${var.vm_disk_controller_type}"
  folder               = "${var.vsphere_folder}"
  guest_os_type        = "ubuntu64Guest"
  http_directory       = "./http"
  insecure_connection  = "true"
  iso_checksum         = "sha256:8762f7e74e4d64d72fceb5f70682e6b069932deedb4949c6975d0f0fe0a91be3"
  iso_urls             = ["https://old-releases.ubuntu.com/releases/24.04/ubuntu-24.04-live-server-amd64.iso"]
  network_adapters {
    network      = "${var.vsphere_portgroup_name}"
    network_card = "vmxnet3"
  }
  password               = "${var.vsphere_password}"
  shutdown_command       = "sudo shutdown -P now"
  ssh_handshake_attempts = "100"
  ssh_password           = "packer"
  ssh_port               = 22
  ssh_timeout            = "20m"
  ssh_username           = "packer"
  storage {
      disk_size             = 24576
      disk_thin_provisioned = true
  }
  storage {
      disk_size             = 65536
      disk_thin_provisioned = true
  }
  username       = "${var.vsphere_user}"
  vcenter_server = "${var.vsphere_server}"
  vm_name        = "${var.vsphere_vm_name}"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.vsphere-iso.sexigraf"]

#  provisioner "shell" {
#    skip_clean = true
#    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} {{ .Path }} ; rm -f {{ .Path }}"
#    inline = [
#      "rm -f /etc/sudoers.d/packer > /dev/null 2>&1",
#      "userdel -rf packer > /dev/null 2>&1"
#    ]
#  }
}
