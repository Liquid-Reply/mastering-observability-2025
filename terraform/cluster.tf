resource "google_service_account" "default" {
  account_id   = "gke-mastering-obs-node-sa"
  display_name = "Mastering Observability GKE Node Service Account"
  project = google_project_service.gke.project
  
}

resource "google_container_cluster" "mastering-observability" {
  name                      = "mastering-observability"
  project = google_project_service.gke.project
  location                  = "europe-west9"
  enable_l4_ilb_subsetting  = true

  network    = "default"
  subnetwork = "default"
  remove_default_node_pool = true
  initial_node_count = 1
  
  deletion_protection = false
  depends_on = [ google_project_service.gke ]
}

resource "google_container_node_pool" "primary_np" {
  name       = "mastering-observability-np-1"
  location   = "europe-west9"
  cluster    = google_container_cluster.mastering-observability.name
  project = google_project_service.gke.project

  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 4
    location_policy = "BALANCED"
  }

  node_config {
    preemptible  = false
    machine_type = "e2-standard-4"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_project_service" "gke" {
  project = "liquid-mastering-obs-543"
  service = "container.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_on_destroy = false
}
