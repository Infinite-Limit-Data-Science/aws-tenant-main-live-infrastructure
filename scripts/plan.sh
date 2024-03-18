#!/bin/bash

echo "Executing plan-all for $ENV..."

terragrunt run-all plan --terragrunt-working-dir infrastructure --terragrunt-non-interactive