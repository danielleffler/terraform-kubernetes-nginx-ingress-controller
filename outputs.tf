output "lb" {
  value = "${data.aws_lb.ingress-nginx}"
  description = "The loadbalancer object created by kubernetes service"
}
