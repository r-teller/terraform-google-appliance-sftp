terraform {
  required_version = "1.0.0"

  required_providers {
    google      = "4.4.0"
    google-beta = "4.4.0"
  }

  # The storage bucket needs to be created before it can be used here in the backend
  # backend "gcs" {
  #   bucket = "__BUCKET_NAME__"
  #   prefix = "__FOLDER_NAME__/__DEPLOYMENT_NAME__"
  # }
}