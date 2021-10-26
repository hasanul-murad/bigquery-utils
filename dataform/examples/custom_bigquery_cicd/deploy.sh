#!/bin/bash

cleanup() {
 rm -rf node_modules
 rm -f package-lock.json
 rm -f .df-credentials.json
 bq --project_id "${PROD_PROJECT_ID}" rm -r -f --dataset dataform_prod
 bq --project_id "${TEST_PROJECT_ID}" rm -r -f --dataset dataform_test
 rm -rf definitions/ddl_scale_test
 rm -rf apply_table_changes/
 rm -rf create_test_env/
}

generate_dataform_configs(){
  local project_id=$1
  local dataset_id=$2
  sed "s|\${PROJECT_ID}|${project_id}|g" dataform_dev.json \
  | sed "s|\${DATASET_ID}|${dataset_id}|g" > dataform.json
  generate_dataform_credentials "${project_id}" .
  #redirect to null to avoid noise
  dataform install > /dev/null 2>&1
}

generate_dataform_credentials(){
  local project_id=$1
  local dataform_dir=$2
  # Create an .df-credentials.json file as shown below
  # in order to have Dataform pick up application default credentials
  # https://cloud.google.com/docs/authentication/production#automatically
  echo "{\"projectId\": \"${project_id}\", \"location\": \"${BQ_LOCATION}\"}" > "${dataform_dir}"/.df-credentials.json
}

add_symbolic_dataform_dependencies(){
  local target_dir=$1
  # Create symbolic links to dataform config files and node_modules
  # to save time and not duplicate resources
  ln -sf "$(pwd)"/package.json "${target_dir}"/package.json
  ln -sf "$(pwd)"/node_modules/ "${target_dir}"/node_modules
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
    # Add "config { hasOutput: true }" to top of file
    sed -i "1s|^|config { hasOutput: true }\n|" "${destination}"
    sed -i -r "s|CREATE TABLE [0-9A-Za-z_]+\.[0-9A-Za-z_\-]+|CREATE TABLE \${self()}|" "${destination}"
  done <<<"$(
    find "${ddl_dir}" -type f -name "*.sql"
  )"
}

deploy_mock_production_env() {
  local project_id=$1
  local dataset_id=$2
  generate_dataform_credentials "${project_id}" create_prod_env
  sed "s|\${PROJECT_ID}|${project_id}|g" dataform_dev.json \
  | sed "s|\${DATASET_ID}|${dataset_id}|g" > create_prod_env/dataform.json
  # Add sym links to Dataform configs/dependencies
  add_symbolic_dataform_dependencies create_prod_env
  dataform run create_prod_env/
}

deploy_ddls_in_test_env() {
  local project_id=$1
  local dataset_id=$2
  mkdir -p create_test_env/definitions
  generate_dataform_credentials "${project_id}" create_test_env
  sed "s|\${PROJECT_ID}|${project_id}|g" dataform_dev.json \
  | sed "s|\${DATASET_ID}|${dataset_id}|g" > create_test_env/dataform.json
  add_symbolic_dataform_dependencies create_test_env
  # Change .sql extension DDLs to .sqlx and
  # move them into Dataform definitions folder
  copy_sql_and_rename_to_sqlx source_ddls create_test_env/definitions
  dataform run create_test_env/
}

deploy_ddl_changes() {
  local project_id=$1
  local dataset_id=$2
  python3 table_sync.py source_ddls \
    --output-ddl-dir=apply_table_changes/definitions \
    --test-project-id="${TEST_PROJECT_ID}" \
    --test-dataset-id="${TEST_DATASET_ID}" \
    --prod-project-id="${PROD_PROJECT_ID}" \
    --prod-dataset-id="${PROD_DATASET_ID}"
  generate_dataform_credentials "${project_id}" apply_table_changes
    sed "s|\${PROJECT_ID}|${project_id}|g" dataform_dev.json \
  | sed "s|\${DATASET_ID}|${dataset_id}|g" > apply_table_changes/dataform.json
  add_symbolic_dataform_dependencies apply_table_changes
  dataform run apply_table_changes/
}

set_env_vars(){
  # For now, this build script assumes all BigQuery environments
  # live in the same location which you specify below.
  export BQ_LOCATION=US

  # PROD project points to the live BigQuery environment
  # which must be kept in sync with DDL changes.
  export PROD_PROJECT_ID=deleodanny
  export PROD_DATASET_ID=dataform_prod

  # DDLs will be staged in the TEST project
  export TEST_PROJECT_ID=deleodanny
  export TEST_DATASET_ID=dataform_test

  # This is the project which will receive DDL changes
  export DEPLOY_PROJECT_ID=deleodanny
  export DEPLOY_DATASET_ID=dataform_prod
}

main(){
  set_env_vars

  # Cleaning only necessary when running locally to simulate
  # runtimes of real builds that start from scratch.
  cleanup

  generate_dataform_configs $TEST_PROJECT_ID $TEST_DATASET_ID

  deploy_mock_production_env $PROD_PROJECT_ID $PROD_DATASET_ID
  deploy_ddls_in_test_env $TEST_PROJECT_ID $TEST_DATASET_ID
  deploy_ddl_changes $DEPLOY_PROJECT_ID $DEPLOY_DATASET_ID
}

main

