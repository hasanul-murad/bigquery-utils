#!/bin/bash

cleanup() {
 rm -rf node_modules
 rm -f package-lock.json
 rm -f .df-credentials.json
}

dataform install
# Create an .df-credentials.json file as shown below
# in order to have Dataform pick up application default credentials
# https://cloud.google.com/docs/authentication/production#automatically
echo '{"projectId": "", "location": "US"}' > .df-credentials.json
dataform run

# Cleaning only necessary when running locally
cleanup