



#
# cloud connector connector configuration
#
variable "codebuild_project_arn" {
  type        = string
  description = "ARN for the codebuild job"
}

#
# general
#

variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "scc"
}

variable "region" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "customization of tags to be assigned to all resources. <br/>always include 'product' default tag for resource-group proper functioning.<br/>can also make use of the [provider-level `default-tags`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags)"
  default = {
    "product" = "Sysdig Secure Vulnerability scanner"
  }
}


