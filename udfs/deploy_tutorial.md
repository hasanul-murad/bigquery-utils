# Deploy all UDFs Using Dataform

## Let's get started!

This guide will show you how to deploy all the UDFs in this repo using Dataform running in Cloud Build.

### 1. Clone this repo

   ```bash
   git clone https://github.com/GoogleCloudPlatform/bigquery-utils.git
   cd bigquery-utils/udfs
   ```
### 1. Authenticate using the Cloud SDK and set the BigQuery project in which you'll deploy your UDF(s):

   ```bash 
   gcloud init
   ```

### 1. Enable the Cloud Build API and grant the default Cloud Build service account the BigQuery Job User and Data Editor roles
   ```bash
   gcloud services enable cloudbuild.googleapis.com && \
   gcloud projects add-iam-policy-binding \
     $(gcloud config get-value project) \
     --member=serviceAccount:$(gcloud projects describe $(gcloud config get-value project) --format="value(projectNumber)")"@cloudbuild.gserviceaccount.com" \
     --role=roles/bigquery.user && \
   gcloud projects add-iam-policy-binding \
     $(gcloud config get-value project) \
     --member=serviceAccount:$(gcloud projects describe $(gcloud config get-value project) --format="value(projectNumber)")"@cloudbuild.gserviceaccount.com" \
     --role=roles/bigquery.dataEditor
   ```
### 1. Deploy the UDFs by submitting the following:

   ```bash
   # Deploy to US
   gcloud builds submit . --config=deploy.yaml --substitutions _BQ_LOCATION=US
   ```
   > Note: Deploy to a different location by setting `_BQ_LOCATION` to your own
   > desired value.\
   > [Click here](https://cloud.google.com/bigquery/docs/locations#supported_regions)
   > for a list of supported locations.

## Congratulations 🎉

You have successfully deployed all UDFs!
