#!/bin/bash

PROJECT_ID=danny-bq
BQ_LOCATION=US

cleanup() {
 rm -rf node_modules
 rm -f package-lock.json
 rm -f .df-credentials.json
 bq rm -r -f --dataset dataform_prod
 bq rm -r -f --dataset dataform
 rm -rf definitions/ddl_scale_test
}

handle_new_ddls(){
  local updated_ddls_dir=$1
  local new_columns=$2
  local sql_files
  sql_files=$(find "${updated_ddls_dir}" -type f -name "*.sqlx")
  local new_ddl_select
  new_ddl_select="AS SELECT *, ${new_columns} FROM \${self()}"
  while read -r file; do
    if [[ -n $file ]]; then
      # Add "config { hasOutput: true }" to top of file
      sed -i '' "1s|^|config { hasOutput: true }\n|" "${file}"
      # Add new default values to columns
      sed -i '' "s|;| ${new_ddl_select}|" "${file}"
    fi
  done <<<"${sql_files}"
}

add_dataform_dependencies(){
  local target_dir=$1
  # Create symbolic links to dataform config files and node_modules
  # to save time and not duplicate resources
  ln -sf "$(pwd)"/dataform.json "${target_dir}"/dataform.json
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

# Cleaning only necessary when running locally to simulate
# runtimes of real builds that start from scratch.
cleanup

#python3 generate_ddls.py
dataform install

# Create an .df-credentials.json file as shown below
# in order to have Dataform pick up application default credentials
# https://cloud.google.com/docs/authentication/production#automatically
echo "{\"projectId\": \"${PROJECT_ID}\", \"location\": \"${BQ_LOCATION}\"}" > .df-credentials.json

# Create a mock prod dataset
bq mk --dataset dataform_prod
add_dataform_dependencies create_prod_env
# Change .sql extension DDLs to .sqlx and
# move them into Dataform definitions folder
copy_sql_and_rename_to_sqlx source_ddls create_prod_env/definitions

add_dataform_dependencies create_test_env
add_dataform_dependencies apply_table_changes

dataform run create_prod_env/
dataform run create_test_env/

handle_new_ddls apply_table_changes/definitions " 'default value' AS new_col "
dataform run apply_table_changes/

