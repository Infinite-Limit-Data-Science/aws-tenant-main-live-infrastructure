remote_state {
  backend   = "s3"
  generate  = {
    path        = "backend.tf"
    if_exists   = "overwrite"
  }
  config    = {
    bucket          = get_env("STATE_BUCKET", "")
    key             = "${get_env("PROJECT_NAME", "")}/${lower(get_env("ENV",""))}/infrastructure/${path_relative_to_include()}/terraform.tfstate"
    region          = "us-east-1"
    encrypt         = true
    dynamodb_table  = get_env("STATE_LOCK_TABLE", "")
  }
}