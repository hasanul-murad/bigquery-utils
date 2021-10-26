#!/bin/bash

echo "{\"projectId\": \"${PROJECT_ID}\", \"location\": \"${BQ_LOCATION}\"}" > .df-credentials.json
dataform install
dataform run ${_DATAFORM_ACTIONS} ${_DATAFORM_TAGS}