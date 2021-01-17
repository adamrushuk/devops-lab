#! /usr/bin/env bash
#
# installs and runs tflint with tflint-ruleset-azurerm plugin
# https://github.com/terraform-linters/tflint-ruleset-azurerm

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

message="Downloading tflint and azurerm plugin"
echo "STARTED: $message..."

# download tflint-ruleset-azurerm plugin
curl -sL "$(curl -Ls https://api.github.com/repos/terraform-linters/tflint-ruleset-azurerm/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" -o tflint-ruleset-azurerm_linux_amd64.zip && unzip tflint-ruleset-azurerm_linux_amd64.zip && rm tflint-ruleset-azurerm_linux_amd64.zip

# move tflint-ruleset-azurerm plugin to correct path
install -D -m 777 tflint-ruleset-azurerm /home/vscode/.tflint.d/plugins/tflint-ruleset-azurerm

echo "FINISHED: $message."

# check versions
tflint --version

# create tflint config
# cat > .tflint.hcl << EOF
# plugin "azurerm" {
#     enabled = true
# }
# EOF
# cat .tflint.hcl
