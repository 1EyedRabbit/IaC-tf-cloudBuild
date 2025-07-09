variable "project" {
  type    = string
  default = "cts01-pratikkamble"
}

variable "build_id" {
  type        = string
  description = "The Cloud Build build ID for resource isolation"
}
