#!/bin/bash

PROJECT_ID=danny-bq
BQ_LOCATION=US

cleanup() {
 rm -rf node_modules
 rm -f package-lock.json
 rm -f .df-credentials.json
 bq rm -r -f --dataset dataform
 rm -rf definitions/ddl_scale_test
}

handle_new_ddls(){
  local updated_ddls_dir
  updated_ddls_dir=$1
  local new_columns
  new_columns=$2
  local sql_files
  sql_files=$(find "${updated_ddls_dir}" -type f -name "*.sql")
  local new_ddl_select
  new_ddl_select="AS SELECT *, ${new_columns} FROM \${self()}"
  while read -r file; do
    sed -i '' "s|;| ${new_ddl_select}|g" "${file}"
  done <<<"${sql_files}"
}

# Cleaning only necessary when running locally to simulate
# runtimes of real builds that start from scratch.
cleanup

python3 generate_ddls.py
dataform install
# Create an .df-credentials.json file as shown below
# in order to have Dataform pick up application default credentials
# https://cloud.google.com/docs/authentication/production#automatically
echo "{\"projectId\": \"${PROJECT_ID}\", \"location\": \"${BQ_LOCATION}\"}" > .df-credentials.json
handle_new_ddls updated_ddls " 'default value' AS new_col "
dataform run

