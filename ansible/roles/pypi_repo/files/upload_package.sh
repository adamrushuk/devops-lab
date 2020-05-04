#!/bin/bash
#
# creates and uploads python package

# ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# install twine
echo "installing twine..."
pip3 install --user twine

# info
echo "show version info..."
python3 --version
pip3 --version
pip3 show setuptools wheel twine

# create package
# cd hello
echo "creating package..."
python3 setup.py sdist

# check
# twine check dist/*

# publish
echo "uploading package..."
twine upload --username "$USERNAME" --password "$PASSWORD" --repository-url "$REPO_URL/" dist/*

# install from private pypi repo
# pip3 install --index-url http://my.package.repo/simple/ SomePackage
echo "installing package..."
pip3 install --user --index-url "$REPO_URL/simple" "$PACKAGE_NAME"
pip3 list --local | grep "$PACKAGE_NAME"

# uninstall
# pip3 uninstall --yes "$PACKAGE_NAME"
