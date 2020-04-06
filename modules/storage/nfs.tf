resource "null_resource" "module_depends_on" {
  triggers = {
    value = "${length(var.module_depends_on)}"
  }
}

resource "google_filestore_instance" "instance" {
  depends_on = [null_resource.module_depends_on]
  name = var.name
  zone = var.zone
  tier = "STANDARD"

  file_shares {
    capacity_gb = var.capacity
    name        = "vastenshare1"
  }

  networks {
    network = "vasten-network"
    modes   = ["MODE_IPV4"]
  }
}


resource "null_resource" "persistent_vol_setup" {
  depends_on = [google_filestore_instance.instance]
  provisioner "local-exec" {
    command = "/bin/sed -e 's/fileserver_name/${var.fileserver_name}/' -e 's/vasten_share_server_ip/${google_filestore_instance.instance.networks[0].ip_addresses[0]}/' -e 's/fileserver_name/${var.capacity}/' -e 's/storage_limit/${var.storage}/' ../templates/persistent_vol_template.txt > ../templates/persistent_vol.txt"

  }
}

resource "null_resource" "delay" {
  depends_on = [google_filestore_instance.instance, null_resource.persistent_vol_setup]
  provisioner "local-exec" {
      command = "sleep 120"
    }

}

resource "null_resource" "persistent_vol" {
  depends_on = [google_filestore_instance.instance, null_resource.persistent_vol_setup, null_resource.delay]
  provisioner "local-exec" {
    command = "mv ../templates/persistent_vol.txt ../templates/persistent_vol.yaml && /home/scriptuit/google-cloud-sdk/bin/kubectl create -f ../templates/persistent_vol.yaml"
  }
}

resource "null_resource" "after" {
  depends_on = [google_filestore_instance.instance, null_resource.persistent_vol_setup, null_resource.persistent_vol]
  provisioner "local-exec" {
    command = "sleep 300"
  }
}

resource "null_resource" "persistent_vol_claim_setup" {
  depends_on = [google_filestore_instance.instance]
  provisioner "local-exec" {
    command = "/bin/sed -e 's/fileserver_name/${var.fileserver_name}/' -e 's/capacity/${var.capacity}/' ../templates/persistent_vol_template.txt > ../templates/persistent_vol.txt"

  }
}


resource "null_resource" "persistent_vol_claim" {
  depends_on = [google_filestore_instance.instance, null_resource.persistent_vol, null_resource.after ]
  provisioner "local-exec" {
    command = "/home/scriptuit/google-cloud-sdk/bin/kubectl create -f ../templates/persistent_vol_claim.yaml"
  }
}

resource "null_resource" "daemon_template" {
  depends_on = [google_filestore_instance.instance]
  provisioner "local-exec" {
    command = "/bin/sed -e 's/fileserver_name/${var.fileserver_name}/' -e 's/prefix/${var.prefix}/' -e 's/image_repo_path/${var.image_repo_name}/' ../templates/persistent_vol_template.txt > ../templates/persistent_vol.txt"

  }
}

resource "null_resource" "daemon_set_with_mnt" {
  depends_on = [google_filestore_instance.instance, null_resource.persistent_vol_claim]
  provisioner "local-exec" {
    command = "/home/scriptuit/google-cloud-sdk/bin/kubectl apply -f ../templates/daemon_set_with_mnt.yaml"
  }
}


/*

# Template for initial configuration bash script
data "template_file" "persistent_vol" {
  depends_on = [google_filestore_instance.instance]

  template = "${file("~/Documents/Mehul/Vasten_Cloud/vasten_terraform/templates/persistent_vol.tpl")}"
  vars = {
    vasten_share_path =  google_filestore_instance.instance.name
    vasten_share_server_ip = google_filestore_instance.instance.networks[0].ip_addresses[0]
  }
}

# Template for initial configuration bash script
data "template_file" "persistent_vol_claim" {
  depends_on = [google_filestore_instance.instance]

  template = "${file("~/Documents/Mehul/Vasten_Cloud/vasten_terraform/templates/persistent_vol_claim.tpl")}"

}

# Template for initial configuration bash script
data "template_file" "daemon_set" {
  depends_on = [google_filestore_instance.instance]

  template = "${file("~/Documents/Mehul/Vasten_Cloud/vasten_terraform/templates/daemon_set_with_mnt.tpl")}"

  vars = {
    VASTEN_IMAGE_NAME = var.image_name
    VASTEN_IMAGE_TAG = var.image_tag
  }

}
resource "null_resource" "mount_nfs"{


  depends_on = [google_filestore_instance.instance]

  provisioner "local-exec" {
    command = "sudo smount ${var.mount_ip}:/vastenshare1 ../mount-point-directory"
  }

}
*/
