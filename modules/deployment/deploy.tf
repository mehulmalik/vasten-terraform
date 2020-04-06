variable "module_depends_on" {
  default = [""]
}

variable "module_depends_on_1" {
  default = [""]
}

resource "null_resource" "module_depends_on" {
  triggers = {
    value = "${length(var.module_depends_on)}"
  }
}

resource "null_resource" "module_depends_on_1" {
  triggers = {
    value = "${length(var.module_depends_on_1)}"
  }
}

resource "null_resource" "get_credentials" {
  depends_on  = [null_resource.module_depends_on]
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials vasten-private-cluster --region us-west1"
  }

}

resource "null_resource" "deploy" {
  depends_on  = [null_resource.get_credentials]
  provisioner "local-exec" {
    command = "kubectl create deployment simple-web-app-deploy --image=gcr.io/${var.project_id}/vasten_container_image:latest"
  }

}
