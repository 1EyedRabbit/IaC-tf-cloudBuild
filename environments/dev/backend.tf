terraform {
  backend "gcs" {
    bucket = "cts01-pratikkamble-tfstate"
    prefix = "env/dev"
  }
}
