#!/usr/bin/env bash

# Installs useful Terraform tools and pre-commit

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Install curl if missing
if ! dpkg -s curl ca-certificates > /dev/null 2>&1; then
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends curl ca-certificates
fi

# vars
PRECOMMIT_VERSION=${1:-"2.9.3"}
TFSEC_VERSION=${2:-"0.36.10"}
TERRAFORM_DOCS_VERSION=${3:-"0.10.1"}

# workaround for "cannot use path@version syntax in GOPATH mode" error
export GO111MODULE="on"

# TFSec
go get -u github.com/tfsec/tfsec/cmd/tfsec@v${TFSEC_VERSION}

# Terraform Docs
go get github.com/terraform-docs/terraform-docs@v${TERRAFORM_DOCS_VERSION}

# TODO: install TFLint azurerm plugin
# https://github.com/terraform-linters/tflint-ruleset-azurerm


# pre-commit
sudo apt install -y python3-pip
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade pre-commit==${PRECOMMIT_VERSION}
