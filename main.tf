
provider "google" {  
  credentials = "${file("${var.gcp_key_file}")}"
  project  = "softwarization-net"
  region   = "us-west1"  
}
variable "gcp_key_file" {
}
resource "google_compute_network" "gcp_vpc" {
  name                    = "wnde-acemicrovpc-network"
  project                 = "softwarization-net"
  auto_create_subnetworks = false
}
resource "google_compute_route" "gcp_route1" { 
 name        = "route" 
 project     = "softwarization-net" 
 dest_range  = "0.0.0.0/0"
 network     = "${google_compute_network.gcp_vpc.name}" 
 next_hop_gateway = "default-internet-gateway" 
 priority    = 100 
} 

resource "google_compute_firewall" "gcp_firewall1" { 
 name    = "firewall" 
 network = "${google_compute_network.gcp_vpc.name}" 
 priority = 1000 
 direction = "INGRESS" 
 source_ranges = ["0.0.0.0/0"] 
 allow { 
  protocol = "tcp" 
  ports    = ["80","8080","1000-2000"] 
  } 
} 

resource "google_compute_subnetwork" "gcp_subnet1" { 
 name             = "subnet" 
 ip_cidr_range    = "10.127.0.0/20" 
 network          = "${google_compute_network.gcp_vpc.name}" 
 region           = "us-west1" 
 private_ip_google_access = true 
 enable_flow_logs = false 
} 

resource "google_container_node_pool" "kubernetes-cluster-node-pool1" { 
 name       = "kubernetes-nodes" 
 project    = "softwarization-net" 
 cluster    = "${google_container_cluster.kubernetes-cluster1.name}" 
 location   = "us-west1-a" 
 node_count = "2" 
 node_config { 
  machine_type = "n1-standard-4"     
  oauth_scopes = ["compute-rw","storage-full","pubsub","logging-write","service-control","service-management","monitoring","bigquery", 
  "cloud-platform","cloud-source-repos","cloud-source-repos-ro","datastore","service-control","service-management","taskqueue"] 
  labels {  for = "ReferenceArchitecture" } 
  tags = ["demoproject", "wnde-acemicro"] 
 } 
 autoscaling { 
  min_node_count = "1" 
  max_node_count = "10" 
 } 
 management { 
  auto_repair  = true 
  auto_upgrade  = true 
 } 
} 
 
resource "google_container_cluster" "kubernetes-cluster1" {
 name               = "wnde-acemicro-kubernetes"
 project            = "softwarization-net" 
 location           = "us-west1-a"
 remove_default_node_pool = true
 initial_node_count = 1 
 network            = "${google_compute_network.gcp_vpc.name}" 
 subnetwork         = "${google_compute_subnetwork.gcp_subnet1.name}" 
 enable_legacy_abac = true 
 master_auth { 
  username = "" 
  password = "" 
  client_certificate_config { 
   issue_client_certificate = true 
  } 
 } 
 node_locations = ["us-west1-b"] 
} 

resource "google_compute_instance" "vm_instance1" {
 name         = "myvm8nov"
 machine_type = "f1-micro"
 zone         = "us-central1-a"
 tags         =  ["web"]
 boot_disk {
  initialize_params {
   image = "debian-cloud/debian-9"
   size = "50"
   type = "pd-standard"
  }
 }
 network_interface {
  subnetwork  = "${google_compute_subnetwork.gcp_subnet1.name}" 

  access_config {}
 }
}