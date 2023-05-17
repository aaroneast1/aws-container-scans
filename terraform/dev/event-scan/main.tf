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
