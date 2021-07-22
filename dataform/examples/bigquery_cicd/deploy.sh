#!/bin/bash

cleanup() {
 rm -rf node_modules
 rm -f package-lock.json
 rm -f .df-credentials.json
# bq rm -r -f --dataset dataform
}

handle_new_ddls(){
  local updated_ddls_dir
  updated_ddls_dir=$1
  local sql_files
  sql_files=$(find "${updated_ddls_dir}" -type f -name "*.sql")
  local new_ddl_select
  new_ddl_select="AS SELECT *, 'default value' AS new_col FROM \${self()}"
  while read -r file; do
    sed -i '' "s|;| ${new_ddl_select}|g" "${file}"
  done <<<"${sql_files}"
}

bq rm -r -f --dataset dataform
dataform install
# Create an .df-credentials.json file as shown below
# in order to have Dataform pick up application default credentials
# https://cloud.google.com/docs/authentication/production#automatically
echo '{"projectId": "", "location": "US"}' > .df-credentials.json
handle_new_ddls updated_ddls
dataform run

# Cleaning only necessary when running locally
cleanup