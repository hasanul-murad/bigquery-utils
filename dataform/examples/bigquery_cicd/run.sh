#!/bin/bash

echo "{\"projectId\": \"${PROJECT_ID}\", \"location\": \"${BQ_LOCATION}\"}" > .df-credentials.json
dataform install

if [[ -n "${DATAFORM_ACTIONS}" && -n "${DATAFORM_TAGS}" ]]; then
  dataform run --actions "${DATAFORM_ACTIONS}" --tags "${DATAFORM_TAGS}"
elif [[ -n "${DATAFORM_ACTIONS}" ]]; then
  dataform run --actions "${DATAFORM_ACTIONS}"
elif [[ -n "${DATAFORM_TAGS}" ]]; then
  dataform run --tags "${DATAFORM_TAGS}"
else
  dataform run
fi
