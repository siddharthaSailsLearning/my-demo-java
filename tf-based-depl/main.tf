provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_artifact_registry_repository" "repo" {
  provider = google
  project  = var.project_id
  location = var.region
  repository_id = var.repository_id
  format = "DOCKER"
  description = "Artifact Registry for images"
}

resource "google_artifact_registry_repository_iam_member" "writer" {
  repository = google_artifact_registry_repository.repo.id
  role = "roles/artifactregistry.writer"
  member = "serviceAccount:${var.build_service_account_email}"
}

resource "google_artifact_registry_repository_iam_member" "reader" {
  repository = google_artifact_registry_repository.repo.id
  role = "roles/artifactregistry.reader"
  member = "serviceAccount:${var.build_service_account_email}"
}
# roles/container.viewer
# roles/container.developer
resource "google_container_cluster" "primary" {
  name               = var.cluster_name
  location           = var.region
  initial_node_count = 1
  remove_default_node_pool = true
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "primary_pool" {
  name       = "primary-pool"
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location
  node_config {
    machine_type = var.node_machine_type
    service_account = var.node_service_account_email
  }
  initial_node_count = var.node_count
}