# Nexus PyPI Repository Notes

Ansible is used to create the PyPI repo via REST API.

Once Ansible has created the Nexus PyPI repo, follow the examples below for testing.

## Create and Publish Python Package

```bash
# move to example module folder
cd nexus/repositories/pypi/hello

# create package
python3 setup.py sdist

# install twine
pip3 install --user twine

# check
python3 -m twine check dist/*

# publish
# this will prompt for the username and password
python3 -m twine upload --repository-url https://nexus.thehypepipe.co.uk/repository/pypi-repo/ dist/*

# publish without prompts
NEW_ADMIN_PASSWORD="<ADMIN_PASSWORD>"
python3 -m twine upload --username admin --password "$NEW_ADMIN_PASSWORD" --repository-url https://nexus.thehypepipe.co.uk/repository/pypi-repo/ dist/*

# install from private pypi repo
# pip install --index-url http://my.package.repo/simple/ SomePackage
pip3 list --local | grep adams-package
pip3 install --user --index-url https://nexus.thehypepipe.co.uk/repository/pypi-repo/simple adams-package
pip3 list --local | grep adams-package

# search nexus repo
pip3 search --index https://nexus.thehypepipe.co.uk/repository/pypi-repo/pypi adams-package

# uninstall
pip3 uninstall --yes adams-package
```
