variable "name" {
  type = string
  default = "scc"
}

variable "region" {
  type = string
}

variable "codebuild_environment_variables" {
  type = list(object(
    {
      name = string
      value = string
    }
  ))
}

variable "tags" {
  type        = map(string)
  description = "customization of tags to be assigned to all resources. <br/>always include 'product' default tag for resource-group proper functioning.<br/>can also make use of the [provider-level `default-tags`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags)"
  default = {
    "product" = "Sysdig Secure Vulnerability scanner"
  }
}

