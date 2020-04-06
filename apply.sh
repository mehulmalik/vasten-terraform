#!/bin/bash
cd ~/vasten_terraform/main-modules
terraform init
terraform apply --auto-approve=true -lock=false --var-file=../vars/terraform.tfvars
