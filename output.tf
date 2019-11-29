locals {

kubeconfig = <<KUBECONFIG


apiVersion: v1
kind: Config
clusters:
- name: kubernetes
  cluster:
    server: https://${google_container_cluster.kubernetes-cluster1.endpoint}
    certificate-authority-data: ${google_container_cluster.kubernetes-cluster1.master_auth.0.cluster_ca_certificate}

users:
- name: kubernetes_admin_user
  user:
    client-certificate-data: ${google_container_cluster.kubernetes-cluster1.master_auth.0.client_certificate}
    client-key-data: ${google_container_cluster.kubernetes-cluster1.master_auth.0.client_key}  

current-context: gcp_kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes_admin_user
  name: gcp_kubernetes


KUBECONFIG

}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}


