
/*
######################################################################
# Display Output Public Instance
######################################################################
output "uc1_public_address"  { value = "${module.network.uc1_public_address}"}
*/



module "network" {
  source = "../modules/network"

  name_prefix = var.gcp_prefix

  project     = var.gcp_project

  region      = var.gcp_region

  cidr_block  = var.network_primary_cidr

  cidr_subnetwork_width_delta = var.network_primary_width

  cidr_subnetwork_spacing     = var.network_primary_spacing

  secondary_cidr_block        = var.network_secondary_cidr

  secondary_cidr_subnetwork_width_delta = var.network_secondary_width

  secondary_cidr_subnetwork_spacing     = var.network_secondary_spacing

  allowed_public_restricted_subnetworks = [""]
}

/*
module "registry" {
  source = "../modules/registry"

}


module "deploy" {
  module_depends_on = ["${module.registry.wait_flag}"]
  module_depends_on_1 = ["${module.gke_cluster.wait_flag}"]
  source = "../modules/deployment"
  project_id = var.project_id
}
*/

module "gke_cluster" {
  # Use a version of the gke-cluster module that supports Terraform 0.12
  source = "../modules/cluster"

  name = var.cluster_name

  project  = var.project_id

  location = var.gcp_location

  initial_node_count = var.cluster_nodes

  machine_type = var.cluster_machine_type

  machine_cores = var.cluster_machine_cores

  localStore_capacity = var.cluster_localStore_capacity

  network  = module.network.network

  vpc_network = module.network.private
  # We're deploying the cluster in the 'public' subnetwork to allow outbound internet access
  # See the network access tier table for full details:
  # https://github.com/gruntwork-io/terraform-google-network/tree/master/modules/vpc-network#access-tier
  subnetwork = module.network.public_subnetwork

  # When creating a private cluster, the 'master_ipv4_cidr_block' has to be defined and the size must be /28
  master_ipv4_cidr_block = var.master_ipv4_cidr_block

  # This setting will make the cluster private
  enable_private_nodes = "false"

  # To make testing easier, we keep the public endpoint available. In production, we highly recommend restricting access to only within the network boundary, requiring your users to use a bastion host or VPN.
  disable_public_endpoint = "false"

  # With a private cluster, it is highly recommended to restrict access to the cluster master
  # However, for testing purposes we will allow all inbound traffic.
  master_authorized_networks_config = [
    {
      cidr_blocks = [
        {
          cidr_block   = "0.0.0.0/0"
          display_name = "all-for-testing"
        },
      ]
    },
  ]

  cluster_secondary_range_name = module.network.public_subnetwork_secondary_range_name
}



module "storage" {

  source = "../modules/storage"

  module_depends_on = ["${module.gke_cluster.name}"]

  name = var.nfs_name

  zone = var.nfs_zone

  prefix = var.gcp_prefix

  storage = "1T"

  image_name = var.image_name

  image_repo_name = var.image_repository_name

  image_tag = var.image_tag

  capacity = var.nfs_capacity

  network = module.network.network
}
