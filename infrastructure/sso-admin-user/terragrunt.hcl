include "root" {
  path              = find_in_parent_folders()
}

terraform {
  source            =  "${path_relative_from_include()}/../modules/aws-sso-user//modules"
}

locals {
  settings_default  = yamldecode(file("../settings-defaults.yml"))
  settings_env      = yamldecode(file("../settings-${lower(get_env("ENV",""))}.yml"))
  settings = merge(
    local.settings_default,
    local.settings_env
  )
}

inputs = {
  name_prefix           = local.settings.name_prefix
  name_suffix           = local.settings.name_suffix
  replication_enabled   = local.settings.replication_enabled
  primary_region        = local.settings.primary_region
  secondary_region      = local.settings.secondary_region
  tags                  = local.settings.tags
}