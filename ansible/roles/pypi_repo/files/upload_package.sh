#!/bin/bash
#
# creates and uploads python package

# ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# debug
# printenv | sort

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
twine upload --username "$1" --password "$2" --repository-url https://nexus.thehypepipe.co.uk/repository/pypi-repo/ dist/*

# install from private pypi repo
# pip install --index-url http://my.package.repo/simple/ SomePackage
echo -e "\ninstalling package..."
pip install --user --index-url https://nexus.thehypepipe.co.uk/repository/pypi-repo/simple adams-package
pip list --local | grep adams-package

# uninstall
pip uninstall --yes adams-package
