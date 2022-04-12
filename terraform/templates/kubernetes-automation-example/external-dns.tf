# External-DNS Deployment

resource "kubernetes_namespace" "external-dns" {
  metadata {
    name = "external-dns"
  }

  depends_on = [
    time_sleep.wait_for_kubernetes
  ]
}

resource "kubernetes_secret" "gandi_api_key_secret" {
  metadata {
    name = "gandi-api-key-secret"
    namespace = "external-dns"
   }

   data = {
     GANDI_KEY = var.gandi_api_key
   }

   type = "Opaque"

   depends_on = [
     kubernetes_namespace.external-dns
   ]
}

resource "kubernetes_deployment" "external-dns" {
  metadata {
    name = "external-dns"
    namespace = "external-dns"
    labels = {
      app = "external-dns"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "external-dns"
      }
    }

    template {
      metadata {
        labels = {
          app = "external-dns"
        }
      }

      spec {
        container {
          name = "external-dns"
          image = "k8s.gcr.io/external-dns/external-dns:v0.11.0"
          args = [
            "--source=ingress",
            "--domain-filter=civo.fournier.io",
            "--provider=gandi"
          ]
          env_from {
            secret_ref {
              name = "gandi-api-key-secret"
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_secret.gandi_api_key_secret
  ]
}
