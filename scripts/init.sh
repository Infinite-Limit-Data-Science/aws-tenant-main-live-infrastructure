#!/bin/bash

echo "Terragrunt init for $ENV..."

terragrunt init --upgrade --terragrunt-working-dir infrastructure --terragrunt-non-interactive