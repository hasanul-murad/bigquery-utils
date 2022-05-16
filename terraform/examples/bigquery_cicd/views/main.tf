resource "google_bigquery_table" "view1" {
  dataset_id = var.dataset_id
  table_id   = "view1"
  view {
    use_legacy_sql = false
    query          = file("${path.module}/sql/view1.sql")
  }
}

resource "google_bigquery_table" "view2" {
  depends_on = [google_bigquery_table.view1, ]
  dataset_id = var.dataset_id
  table_id   = "view2"
  view {
    use_legacy_sql = false
    query          = templatefile("${path.module}/sql/view2.sql", { dataset_id = var.dataset_id })
  }
}