variable "project_region" {
  type = string
  default = "{value}"
}

module "vpc" {
  source = "../../modules/vpc"
  name   = "scc"
  region = "${var.project_region}"
}

module "codebuild" {
  source = "../../modules/codebuild"
  name   = "scc"
  region = "${var.project_region}"
  codebuild_environment_variables = [
    { "name":"PROJECT_NAME","value":"scc" },
    { "name":"ACCOUNT_ID","value":"{value}"},
    { "name":"REGION","value":"${var.project_region}"}
  ]
}

module "events" {
  source = "../../modules/events"
  name                  = "scc"
  region                = "${var.project_region}"
  codebuild_project_arn = module.codebuild.project_arn 
}

module "ecs" {
  source = "../../modules/ecs"
  vpc_id                  = module.vpc.vpc_id
  vpc_subnets_private_ids = module.vpc.private_subnets_ids
  codebuild_project_name  = module.codebuild.project_name
  codebuild_project_arn   = module.codebuild.project_arn
  account_id              = "{value}"
  region                  = "${var.project_region}"
  sysdig_secure_url       = "https://eu1.app.sysdig.com"
  events_sqs_url          = module.events.sqs_url
  events_sqs_arn          = module.events.sqs_arn
  image                   = "{value}"
}
