terraform {
  backend "gcs" {
    bucket = "PROJECT_ID-tfstate"
    prefix = "env/prod/${var.build_id}"
  }
}
