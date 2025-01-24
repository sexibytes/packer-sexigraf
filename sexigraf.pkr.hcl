source "vsphere-iso" "sexigraf" {
  http_ip              = "${var.http_bind_address}"
  CPUs                 = 4
  RAM                  = 16384
  boot_command         = ["<esc><esc><esc><esc>e<wait>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "<del><del><del><del><del><del><del><del>", "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\"<enter><wait>", "initrd /casper/initrd<enter><wait>", "boot<enter>", "<enter><f10><wait>"]
  boot_wait            = "3s"
  cluster              = "${var.cluster}"
  host				         = "${var.vsphere_host}"
  convert_to_template  = false
  datastore            = "${var.vsphere_datastore}"
  folder               = "${var.vsphere_folder}"
  guest_os_type        = "ubuntu64Guest"
  http_directory       = "./http"
  insecure_connection  = "true"
  iso_checksum         = "sha256:84aeaf7823c8c61baa0ae862d0a06b03409394800000b3235854a6b38eb4856f"
  iso_urls             = ["https://old-releases.ubuntu.com/releases/jammy/ubuntu-22.04-live-server-amd64.iso"]
  network_adapters {
    network      = "${var.vsphere_portgroup_name}"
    network_card = "vmxnet3"
  }
  password               = "${var.vsphere_password}"
  ssh_handshake_attempts = "100"
  ssh_password           = "packer"
  ssh_port               = 22
  ssh_timeout            = "99m"
  ssh_username           = "packer"
  disk_controller_type = ["pvscsi"]
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

	provisioner "shell" {
	  execute_command = "echo 'packer' | sudo -S sh '{{.Path}}'"
	  scripts = [
      "scripts/base.sh",
      "scripts/graphite.sh",
      "scripts/grafana.sh",
      "scripts/telegraf.sh",
      "scripts/powershell.sh",
      "scripts/sexigraf.sh",
      "scripts/netdata.sh",
      "scripts/govc.sh",
      "scripts/cleanup.sh"
	  ]
	}

	provisioner "shell" {
	  skip_clean       = true
	  execute_command  = "chmod +x {{ .Path }}; sudo env {{ .Vars }} {{ .Path }} ; rm -f {{ .Path }}"

	  inline = [
		"rm -f /etc/sudoers.d/packer > /dev/null 2>&1",
		"userdel -rf packer > /dev/null 2>&1"
	  ]
	}
}
