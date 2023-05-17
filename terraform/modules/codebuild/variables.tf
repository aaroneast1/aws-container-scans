variable "name" {
  type = string
  default = "scc"
}

variable "codebuild_environment_variables" {
  type = list(object(
    {
      name = string
      value = string
    }
  ))
}
