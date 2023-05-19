module "vpc" {
  source = "../../modules/vpc"
  name = "scc"
}

module "codebuild" {
  source = "../../modules/codebuild"

  name = "scc"

  codebuild_environment_variables = [
    { "name":"PROJECT_NAME","value":"scc" },
    { "name":"ACCOUNT_ID","value":"071631413357"},
    { "name":"REGION","value":"eu-central-1"}
  ]
}

module "events" {
  source = "../../modules/events"
  name = "scc"
  codebuild_project_arn = module.codebuild.project_arn 
}

module "ecs" {
  source = "../../modules/ecs"
  vpc_id = module.vpc.vpc_id
  vpc_subnets_private_ids = module.vpc.private_subnets_ids
  codebuild_project_name = module.codebuild.project_name
  codebuild_project_arn = module.codebuild.project_arn
  account_id = "071631413357"
  region = "eu-central-1"
  sysdig_secure_url = "https://eu1.app.sysdig.com"
  events_sqs_url = module.events.sqs_url
  events_sqs_arn = module.events.sqs_arn
  # sqs_queue_name = "${var.name}-service-events"
}
