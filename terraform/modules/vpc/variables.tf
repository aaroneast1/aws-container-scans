variable "name" {
  type = string
  default = "scc"
}

variable "cidr" {
  type = string
  default = "10.0.0.0/20"
}

variable "vpc_azs" {
  type = list(string)
  default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

}
variable "vpc_private_subnets" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "vpc_public_subnets" {
  type = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "tags" {
  type        = map(string)
  description = "customization of tags to be assigned to all resources. <br/>always include 'product' default tag for resource-group proper functioning.<br/>can also make use of the [provider-level `default-tags`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags)"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}



