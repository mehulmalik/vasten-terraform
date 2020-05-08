#!/bin/bash
cd /codebase/vasten-terraform/main-modules
#cd ~/Music/basic
terraform destroy --auto-approve=true -lock=false --var-file=../vars/$1 &
#terraform destroy --auto-approve=true -lock=false --var-file=./variable_config/terraform.tfvars
