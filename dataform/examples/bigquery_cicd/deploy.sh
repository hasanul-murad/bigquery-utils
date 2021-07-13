#!/bin/bash

dataform install
echo '{"projectId": "", "location": "US"}' > .df-credentials.json
dataform run