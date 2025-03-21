resource "google_container_cluster" "autopilot" {
  name                      = "mastering-observability"
  project                   = "liquid-mastering-obs-543"
  location                  = "europe-west9"
  enable_autopilot          = true
  enable_l4_ilb_subsetting  = true

  network    = "default"
  subnetwork = "default"
  
  deletion_protection = false
  depends_on = [ google_project_service.gke ]
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