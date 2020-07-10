// https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.29.0/deploy/static/provider/aws/service-nlb.yaml
resource "kubernetes_service" "lb" {
  metadata {
    name      = local.name
    namespace = kubernetes_namespace.nginx.metadata.0.name

    labels = {
      "app.kubernetes.io/name"       = local.name
      "app.kubernetes.io/part-of"    = kubernetes_namespace.nginx.metadata.0.name
      "app.kubernetes.io/managed-by" = "terraform"
    }

    annotations = var.lb_annotations
  }

  spec {
    type = "LoadBalancer"
    selector = {
      "app.kubernetes.io/name"    = local.name
      "app.kubernetes.io/part-of" = kubernetes_namespace.nginx.metadata.0.name
    }

    external_traffic_policy = "Local"

    dynamic "port" {
      for_each = var.lb_ports

      content {
        name        = port.value.name
        port        = port.value.port
        target_port = port.value.target_port
      }
    }
  }
}

data "aws_lb" "ingress-nginx" {
  name = "${element(split("-", element(split(".", kubernetes_service.lb.load_balancer_ingress.0.hostname), 0)), 0)}"
  depends_on = [kubernetes_service.lb]
}