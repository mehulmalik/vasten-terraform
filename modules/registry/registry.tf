
resource "null_resource" "build_image" {
  provisioner "local-exec" {
    command = "sudo docker build -t gcr.io/vasten/vasten_container_image:latest ../../."
  }
}

resource "null_resource" "push_image" {
  depends_on = [null_resource.build_image]
  provisioner "local-exec" {
    command = "sudo docker push gcr.io/vasten/vasten_container_image:latest"
  }
}
