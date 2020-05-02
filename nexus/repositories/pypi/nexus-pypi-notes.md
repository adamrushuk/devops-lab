# Nexus PyPI Repository Notes

Ansible is used to create the PyPI repo via REST API.

Once Ansible has created the Nexus PyPI repo, follow the examples below for testing.

## Create and Publish Python Package

```bash
# move to example module folder
cd nexus/repositories/pypi/hello

# create package
python setup.py sdist

# install twine
pip install --user twine

# check
twine check dist/*

# publish
# this will prompt for the username and password
twine upload --repository-url https://nexus.thehypepipe.co.uk/repository/pypi-repo/ dist/*

# publish without prompts
NEW_ADMIN_PASSWORD="<ADMIN_PASSWORD>"
twine upload --username admin --password "$NEW_ADMIN_PASSWORD" --repository-url https://nexus.thehypepipe.co.uk/repository/pypi-repo/ dist/*

# install from private pypi repo
# pip install --index-url http://my.package.repo/simple/ SomePackage
pip list --local | grep adams-package
pip install --user --index-url https://nexus.thehypepipe.co.uk/repository/pypi-repo/simple adams-package
pip list --local | grep adams-package

# uninstall
pip uninstall --yes adams-package
```
