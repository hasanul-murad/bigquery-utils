#!/bin/bash

env=$1
tool=$2

#terragrunt run-all apply -refresh-only --terragrunt-non-interactive --terragrunt-working-dir="${env}"/"${tool}"
#terragrunt run-all show -json --terragrunt-non-interactive --terragrunt-working-dir="${env}"/"${tool}" > state.json
#terragrunt run-all plan -json --terragrunt-non-interactive --terragrunt-working-dir=qa > terraform_plan_out.json
#terragrunt run-all plan --terragrunt-non-interactive --terragrunt-working-dir="${env}"/"${tool}"
#terragrunt run-all apply -refresh-only --terragrunt-non-interactive --terragrunt-working-dir="${env}"/"${tool}"
#terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir="${env}"/"${tool}"
#terragrunt run-all destroy --terragrunt-non-interactive

terragrunt run-all apply --terragrunt-non-interactive

# Uncomment below to purge the terragrunt caches
 find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;