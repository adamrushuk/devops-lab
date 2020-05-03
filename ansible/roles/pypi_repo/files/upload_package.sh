#!/bin/bash
#
# creates and uploads python package

# ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# create package
# cd hello
echo -e "\ncreating package..."
python setup.py sdist

# install twine
echo -e "\ninstalling twine..."
pip install --user twine

# check
twine check dist/*

# publish
echo -e "\nuploading package..."
twine upload --username "$USERNAME" --password "$PASSWORD" --repository-url "$REPO_URL/" dist/*

# install from private pypi repo
# pip install --index-url http://my.package.repo/simple/ SomePackage
echo -e "\ninstalling package..."
pip install --user --index-url "$REPO_URL/simple" "$PACKAGE_NAME"
pip list --local | grep "$PACKAGE_NAME"

# uninstall
# pip uninstall --yes "$PACKAGE_NAME"
