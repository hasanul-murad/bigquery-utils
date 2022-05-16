#!/bin/bash

terraform init
terraform apply -auto-approve -var-file=testing.tfvars
#terraform apply -auto-approve -refresh-only -var-file=testing.tfvars