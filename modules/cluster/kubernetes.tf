# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A GKE CLUSTER
# This module deploys a GKE cluster, a managed, production-ready environment for deploying containerized applications.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

resource "google_container_cluster" "cluster" {
  name        = "${var.name}-cluster"
  description = var.description

  project    = var.project
  location   = var.location
  network    = var.network
  subnetwork = var.subnetwork

  logging_service    = var.logging_service
  monitoring_service = var.monitoring_service

  # The API requires a node pool or an initial count to be defined; that initial count creates the
  # "default node pool" with that # of nodes.
  # remove_default_node_pool = true

  initial_node_count = var.initial_node_count

  # ip_allocation_policy.use_ip_aliases defaults to true, since we define the block `ip_allocation_policy`
  ip_allocation_policy {
    // Choose the range, but let GCP pick the IPs within the range
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.cluster_secondary_range_name
  }

  # Optionally control access to the cluster
  private_cluster_config {
    enable_private_endpoint = var.disable_public_endpoint
    enable_private_nodes    = var.enable_private_nodes
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  addons_config {
    http_load_balancing {
      disabled = ! var.http_load_balancing
    }

    horizontal_pod_autoscaling {
      disabled = ! var.horizontal_pod_autoscaling
    }

    network_policy_config {
      disabled = ! var.enable_network_policy
    }
  }

  network_policy {
    enabled = var.enable_network_policy

    # Tigera (Calico Felix) is the only provider
    provider = "CALICO"
  }

  master_auth {
    username = var.basic_auth_username
    password = var.basic_auth_password
  }

  dynamic "master_authorized_networks_config" {
    for_each = var.master_authorized_networks_config
    content {
      dynamic "cidr_blocks" {
        for_each = lookup(master_authorized_networks_config.value, "cidr_blocks", [])
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = lookup(cidr_blocks.value, "display_name", null)
        }
      }
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = var.maintenance_start_time
    }
  }



  # If var.gsuite_domain_name is non-empty, initialize the cluster with a G Suite security group
  dynamic "authenticator_groups_config" {
    for_each = [
      for x in [var.gsuite_domain_name] : x if var.gsuite_domain_name != null
    ]

    content {
      security_group = "gke-security-groups@${authenticator_groups_config.value}"
    }
  }

  node_config {
    image_type   = "COS"
    machine_type = "n1-standard-2"

    labels = {
      private-pools-example = true
    }

    # Add a private tag to the instances. See the network access tier table for full details:
    # https://github.com/gruntwork-io/terraform-google-network/tree/master/modules/vpc-network#access-tier
    tags = [
      var.vpc_network,
      "private-pool-example",
    ]

    disk_size_gb = 30
    disk_type    = "pd-standard"
    preemptible  = false


    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

}

resource "null_resource" "get_creds" {
  depends_on = [google_container_cluster.cluster]
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.name}-cluster --zone=us-west1-a"
  }
}

resource "null_resource" "get_hostnames" {
  depends_on = [null_resource.get_creds, google_container_cluster.cluster]
  provisioner "local-exec" {
    command = "gcloud compute instances list | awk {'print $4'} > ../templates/initial_hostnames_list.txt"
  }
}

resource "null_resource" "update_hostnames_list" {
  depends_on = [null_resource.get_hostnames , google_container_cluster.cluster]
  provisioner "local-exec" {
    command = "sed '/PREEMPTIBLE/d' ../templates/initial_hostnames_list.txt > ../templates/hostnames_list.txt"
  }
}

resource "null_resource" "update_hostnames" {
  depends_on = [null_resource.update_hostnames_list , google_container_cluster.cluster]
  provisioner "local-exec" {
    command = "sudo ../hostfile_update_script.sh > ../initial_hostfile.txt"

  }
}

resource "null_resource" "update_final_hostnames" {
  depends_on = [null_resource.get_hostnames , google_container_cluster.cluster, null_resource.update_hostnames]
  provisioner "local-exec" {
    command = "sed '/hostname_2/d' ../initial_hostfile.txt > ../hostfile.txt"
  }
}

resource "null_resource" "build_image" {
  depends_on = [ google_container_cluster.cluster, null_resource.update_hostnames]
  provisioner "local-exec" {
    command = "sudo docker build -t gcr.io/gold-braid-268003/vasten-container-image:latest ../."
  }
}

resource "null_resource" "push_image" {
  depends_on = [null_resource.build_image, google_container_cluster.cluster]
  provisioner "local-exec" {
    command = "sudo docker push gcr.io/gold-braid-268003/vasten-container-image:latest"
  }
}






/*
output "ip_addresses" {
  value = []
}

data "template_file" "init" {

  template = "${file("~/Documents/Mehul/Vasten_Cloud/vasten_terraform/hostfile.tmpl")}"

  vars = {

    ip_addrs = "${jsonencode(split(",", var.map))}"

    port = 8080

    alloc_cpu = 1

    max_cpu = 1

  }

}

resource "null_resource" "deploy" {
  depends_on  = [null_resource.get_creds, google_container_cluster.cluster]
  provisioner "local-exec" {
    command = "kubectl create deployment simple-web-app-deploy --image=gcr.io/vasten/vasten-container-image:latest"
  }
}

/*
resource "null_resource" "expose" {
  depends_on = [null_resource.get_creds, google_container_cluster.cluster, google_container_node_pool.node_pool, null_resource.deploy]
  provisioner "local-exec" {

  }
 }


*/
