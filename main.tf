
resource "vsphere_virtual_machine" "Windows2012R2" {
  name                      = "${lookup(var.environment_options, format("%s", var.environment))}${var.datacenter}-${var.name}"
  resource_pool_id          = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_cluster_id      = data.vsphere_datastore_cluster.datastore_cluster.id
  num_cpus                  = var.num_cpus
  memory                    = "${var.memory * 1024}"
  guest_id                  = data.vsphere_virtual_machine.Win2012Template.guest_id
  scsi_type                 = data.vsphere_virtual_machine.Win2012Template.scsi_type

  dynamic "network_interface" {
    for_each = data.vsphere_network.network
  
    content {
      network_id = network_interface.value.id
    }
  }

  disk {
    label                   = "disk0"
    size                    = var.os_disk_size
    thin_provisioned	    = "false"
  }

  dynamic "disk" {
    for_each = "${lookup(var.additional_disk_selector_options, format("%s", var.additional_disk_selector))}" ? zipmap(var.additional_disk_number,var.additional_disk_sizes) : zipmap(var.additional_disk_number_null,var.additional_disk_sizes_null)
  
    content {
      label       = "disk${disk.key}"
      unit_number = disk.key
      size        = disk.value
    }
  }

  clone {
    template_uuid 		= data.vsphere_virtual_machine.Win2012Template.id
    timeout      		= 60
    
    customize {
       windows_options{
         computer_name         = "${lookup(var.environment_options, format("%s", var.environment))}${var.datacenter}-${var.name}"
         admin_password        = var.admin_password
         join_domain           = var.join_domain
         domain_admin_user     = var.domain_admin_user
         domain_admin_password = var.domain_admin_password
         auto_logon           = "true"
         auto_logon_count     = "5"
         run_once_command_list= [
         "cmd.exe /C Powershell.exe -ExecutionPolicy Bypass -command {New-Item -Path c:\\Setup -ItemType Directory}",
         "cmd.exe /C Powershell.exe -ExecutionPolicy Bypass {New-Item -Path c:\\Setup -ItemType Directory;[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-WebRequest -Uri https://raw.githubusercontent.com/arpad-herczeg/vmware-vm-build/main/setup.ps1 -OutFile c:\\Setup\\setup.ps1}",
         "cmd.exe /C Powershell.exe -ExecutionPolicy Bypass -File c:\\Setup\\setup.ps1",
          ]
    }

    network_interface {
      ipv4_address = var.network_interface_ip[0]
      ipv4_netmask          = 24
      dns_server_list       = ["3.3.3.10"]
    }
    ipv4_gateway            = "3.3.3.10"
    }
  }
}