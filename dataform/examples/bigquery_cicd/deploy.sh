#!/bin/bash

PROJECT_ID=danny-bq
BQ_LOCATION=US

cleanup() {
 rm -rf node_modules
 rm -f package-lock.json
 rm -f .df-credentials.json
 bq rm -r -f --dataset dataform_prod
 bq rm -r -f --dataset dataform_test
 rm -rf definitions/ddl_scale_test
 rm -rf apply_table_changes/
}

add_dataform_dependencies(){
  local target_dir=$1
  # Create symbolic links to dataform config files and node_modules
  # to save time and not duplicate resources
#  ln -sf "$(pwd)"/dataform.json "${target_dir}"/dataform.json
  ln -sf "$(pwd)"/package.json "${target_dir}"/package.json
  ln -sf "$(pwd)"/node_modules/ "${target_dir}"/node_modules
  ln -sf "$(pwd)"/.df-credentials.json "${target_dir}"/.df-credentials.json
}

copy_sql_and_rename_to_sqlx() {
  local ddl_dir=$1
  local target_dir=$2
  local destination
  local newfilename
  while read -r file; do
    newfilename=$(basename "${file}" | cut -f 1 -d '.')
    destination="${target_dir}/${newfilename}.sqlx"
    printf "Copying file %s to %s\n" "$file" "$destination"
    cp "${file}" "${destination}"
  done <<<"$(find "${ddl_dir}" -type f -name "*.sql")"
}

deploy_mock_production_env() {
  export DATASET_ID=$1
  envsubst < dataform_dev.json > create_prod_env/dataform.json
  # Add sym links to Dataform configs/dependencies
  add_dataform_dependencies create_prod_env
  dataform run create_prod_env/
}

deploy_ddls_in_test_env() {
  export DATASET_ID=$1
  envsubst < dataform_dev.json > create_test_env/dataform.json
  add_dataform_dependencies create_test_env
  # Create a mock test dataset. In real-world scenario, this will
  # be done by Terraform. Only done here for demo.
  bq mk --dataset dataform_test
  # Change .sql extension DDLs to .sqlx and
  # move them into Dataform definitions folder
  copy_sql_and_rename_to_sqlx source_ddls create_test_env/definitions
  dataform run create_test_env/
}

deploy_ddl_changes() {
  python3 table_sync.py source_ddls --output-ddl-dir=apply_table_changes/definitions
  export DATASET_ID=$1
  envsubst < dataform_dev.json > apply_table_changes/dataform.json
  add_dataform_dependencies apply_table_changes
  dataform run apply_table_changes/
}

# Cleaning only necessary when running locally to simulate
# runtimes of real builds that start from scratch.
cleanup

export PROJECT_ID=danny-bq
export DATASET_ID=dataform_prod
envsubst < dataform_dev.json > dataform.json

#python3 generate_ddls.py
dataform install

# Create an .df-credentials.json file as shown below
# in order to have Dataform pick up application default credentials
# https://cloud.google.com/docs/authentication/production#automatically
echo "{\"projectId\": \"${PROJECT_ID}\", \"location\": \"${BQ_LOCATION}\"}" > .df-credentials.json

deploy_mock_production_env dataform_prod
deploy_ddls_in_test_env dataform_test
deploy_ddl_changes dataform_prod


