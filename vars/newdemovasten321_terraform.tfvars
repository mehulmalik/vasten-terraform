project = "gold-braid-268003"
region = "us-west1"
location = "us-west1-a"
name_prefix = "vasten"
project_id = "gold-braid-268003"

# Configuration properties for the vasten-cloud CLI utility
# Make sure the properties file is properly configured to make sure the Cluster is configured properly


#
# Cloud Provider
#

# Possible values are "GCP", "AZURE", "AWS"
# v0.1 supports only GCP
vasten_cloud="GCP"


#
# GCP Configuration
#

# Project name (prefixed to the cloud tags)
# Possible values:
gcp_project="gold-braid-268003"

# The region to setup the cluster in
# Possible values:
gcp_region="us-west1"

# The location to setup the cluster in
# Possible values:
gcp_location="us-west1-a"

# The prefix to tag the cloud resources
# Possible values:
gcp_prefix="vasten"

# The ID of the project created in GCP for setting up the cloud resources
gcp_projectId="566785458490"

# The path to the key file which has aceess to cloud resources
gcp_keyPath="~/Documents/Mehul/Vasten_Cloud/vasten_terraform/vasten-8d684f35b4d1.json"


#
# Network Configuration
#

# Primary Network Configuration
network_primary_cidr="10.0.0.0/16"
network_primary_width = 4
network_primary_spacing = 0

# Secondary Network Configuration
network_secondary_cidr="10.1.0.0/16"
network_secondary_width=4
network_secondary_spacing=0

# Network Logs Enabled (Possible values: true/false)
network_logs=true

#
# Operating System
#
os_name="centos"
os_version="7"

#
# Tool Details
#
tool_name="vasten"
tool_version=""

#
# Registry
#
image_repository_name = "gcr.io/gold-braid-268003/vasten_container_image:latest"
image_name = "vasten_container_image"
image_tag = "latest"
#
# Cluster
#
cluster_name="newdemovasten321"
cluster_nodes=2
cluster_machine_type="n1-standard"
cluster_machine_cores=2
cluster_localStore_capacity=30

#
# NFS
#
nfs_name = "vastenshare1"
nfs_zone = "us-west1-a"
nfs_capacity = 1024

#
# Input Data Storage
#
inputdata_cloud=""
inputdata_host=""
inputdata_capacity=""
inputdata_mountpoint=""
