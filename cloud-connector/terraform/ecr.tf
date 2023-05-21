resource "aws_ecr_repository" "cloud_connector" {
  name                 = "cloudconnector"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}