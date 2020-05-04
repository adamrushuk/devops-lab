from setuptools import setup

# read the contents of your README file
from os import path
this_directory = path.abspath(path.dirname(__file__))
with open(path.join(this_directory, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

setup(
    name='adams-package',
    version='1.0.0',
    description='Adams test package',
    long_description=long_description,
    long_description_content_type='text/markdown',
    author='Adam Rush',
    author_email='adam@example.com',
    url='https://github.com/adamrushuk/aks-nexus-velero/tree/develop/ansible/roles/pypi_repo/files/hello/',
    license='MIT',
    packages=['helloworld'],
    zip_safe=False
)
