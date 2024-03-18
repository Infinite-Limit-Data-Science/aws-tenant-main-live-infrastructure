#!/bin/bash

echo "Executing apply-all for $ENV..."

terragrunt run-all apply --terragrunt-working-dir infrastructure --terragrunt-non-interactive