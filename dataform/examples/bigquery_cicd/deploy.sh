#!/bin/bash

cleanup() {
 rm -rf node_modules
 rm -f package-lock.json
 rm -f .df-credentials.json
}

dataform install
echo '{"projectId": "", "location": "US"}' > .df-credentials.json
dataform run

# Cleaning only necessary when running locally
cleanup