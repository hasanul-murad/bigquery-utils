#!/bin/bash

echo "Running YAPF"
/Users/ddeleo/danieldeleo/bigquery-utils/tools/cloud_functions/gcs_event_based_ingest/venv/bin/python3 -m yapf -ir --style=google table_sync.py

echo "Running ISORT"
/Users/ddeleo/danieldeleo/bigquery-utils/tools/cloud_functions/gcs_event_based_ingest/venv/bin/python3 -m isort table_sync.py

echo "Running FLAKE8"
/Users/ddeleo/danieldeleo/bigquery-utils/tools/cloud_functions/gcs_event_based_ingest/venv/bin/python3 -m flake8 table_sync.py

echo "Running PYLINT"
/Users/ddeleo/danieldeleo/bigquery-utils/tools/cloud_functions/gcs_event_based_ingest/venv/bin/python3 -m pylint table_sync.py

echo "Running MYPY"
/Users/ddeleo/danieldeleo/bigquery-utils/tools/cloud_functions/gcs_event_based_ingest/venv/bin/python3 -m mypy table_sync.py