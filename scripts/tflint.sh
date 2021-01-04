#! /usr/bin/env bash
#
# installs and runs tflint with tflint-ruleset-azurerm plugin

# ensure strict mode and predictable failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# vars
DISABLED_RULES=("azurerm_log_analytics_workspace_invalid_retention_in_days")

message="Downloading tflint and azurerm plugin"
echo "STARTED: $message..."

# download tflint
curl -L "$(curl -Ls https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" -o tflint.zip && unzip tflint.zip && rm tflint.zip

# download tflint-ruleset-azurerm plugin
curl -L "$(curl -Ls https://api.github.com/repos/terraform-linters/tflint-ruleset-azurerm/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" -o tflint-ruleset-azurerm_linux_amd64.zip && unzip tflint-ruleset-azurerm_linux_amd64.zip && rm tflint-ruleset-azurerm_linux_amd64.zip

# move tflint-ruleset-azurerm plugin to correct path
install -D -m 777 tflint-ruleset-azurerm ./.tflint.d/plugins/tflint-ruleset-azurerm

echo "FINISHED: $message."

# check versions
./tflint --version

# create tflint config
cat > .tflint.hcl << EOF
plugin "azurerm" {
    enabled = true
}
EOF
cat .tflint.hcl

# run tflint
TFLINT_LOG=debug ./tflint "$TF_WORKING_DIR" --disable-rule=$DISABLED_RULES
