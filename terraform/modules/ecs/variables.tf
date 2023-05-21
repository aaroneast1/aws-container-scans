variable "name" {
  type = string
  default = "scc"
}

variable "vpc_id" {
  type = string
}
variable "events_sqs_url" {
  type = string
}
variable "events_sqs_arn" {
  type = string
}
variable "codebuild_project_arn" {
  type = string
}
variable "vpc_subnets_private_ids" {
  type = list(string)
}
variable "image" {
  type = string
  # default = ""
}
variable "codebuild_project_name" {
  type = string
  default = ""
}
variable "account_id" {
  type = string
  default = ""
}
variable "region" {
  type = string
  default = ""
}
variable "sysdig_secure_url" {
  type = string
  default = ""
}
variable "sqs_queue_name" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "customization of tags to be assigned to all resources. <br/>always include 'product' default tag for resource-group proper functioning.<br/>can also make use of the [provider-level `default-tags`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags)"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}

# Configure CPU and memory in pairs.
# See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
variable "ecs_task_cpu" {
  type        = string
  description = "Amount of CPU (in CPU units) to reserve for cloud-connector task"
  default     = "256"
}

variable "ecs_task_memory" {
  type        = string
  description = "Amount of memory (in megabytes) to reserve for cloud-connector task"
  default     = "512"
}

variable "connector_ecs_task_role_name" {
  type        = string
  default     = "ECSTaskRole"
  description = "Default ecs cloudconnector task role name"
}

variable "cloudwatch_log_retention" {
  type        = number
  default     = 5
  description = "Days to keep logs for CloudConnector"
}

variable "verify_ssl" {
  type        = bool
  default     = true
  description = "true/false to determine ssl verification for sysdig_secure_url"
}

variable "extra_env_vars" {
  type        = map(string)
  default     = {}
  description = "Extra environment variables for the Cloud Connector deployment"
}
