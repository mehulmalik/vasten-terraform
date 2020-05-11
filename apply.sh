#!/bin/bash
cd /usr/app/codebase/vasten-terraform/main-modules
#cd ~/Music/basic
terraform init
terraform apply --auto-approve=true -lock=false --var-file=../vars/$1 &
#terraform apply --auto-approve=true -lock=false --var-file=./variable_config/terraform.tfvars
