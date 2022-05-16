resource "google_bigquery_table" "population_by_zip_2000" {
  dataset_id = var.dataset_id
  table_id   = "population_by_zip_2000"
  clustering = [
    "zipcode",
    "population"
  ]
  schema = file("${path.module}/json_schemas/population_by_zip_2000.json")
}