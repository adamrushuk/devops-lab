# Nexus Helm Repository Notes

Ansible is used to create the Helm repo via REST API.

Once Ansible has created the Nexus Helm repo, follow the examples below for testing.

## Contents

- [Nexus Helm Repository Notes](#nexus-helm-repository-notes)
  - [Contents](#contents)
  - [Download Example Helm Charts from GitHub](#download-example-helm-charts-from-github)
  - [Upload Helm Charts to Nexus](#upload-helm-charts-to-nexus)
  - [Add Nexus Helm Repo](#add-nexus-helm-repo)
  - [Download Helm Charts from Nexus](#download-helm-charts-from-nexus)

## Download Example Helm Charts from GitHub

Download some example Helm charts, ready to publish into the Nexus Helm repo:

```bash
cd nexus/repositories/helm/charts
helm pull stable/jenkins
helm pull stable/fluentd
helm pull stable/external-dns
```

## Upload Helm Charts to Nexus

To publish Helm charts into the Nexus Helm repo, you must [Upload by HTTP POST](https://help.sonatype.com/repomanager3/formats/helm-repositories#HelmRepositories-UploadbyHTTPPOST):

```bash
# this will prompt for the demo_user password
curl -v -u demo_user https://nexus.thehypepipe.co.uk/repository/helm-repo/ --upload-file fluentd-2.4.0.tgz
curl -v -u demo_user https://nexus.thehypepipe.co.uk/repository/helm-repo/ --upload-file jenkins-1.16.0.tgz
curl -v -u demo_user https://nexus.thehypepipe.co.uk/repository/helm-repo/ --upload-file external-dns-2.20.4.tgz
```

Nexus will automatically update the repo metadata file (`index.yaml`)

## Add Nexus Helm Repo

```bash
# list current repos
helm repo list

# add new repo
# helm repo add nexus http://<username>:<password>@<nexus_url>/repository/helm-hosted/
helm repo add nexus https://nexus.thehypepipe.co.uk/repository/helm-repo/

# confirm nexus repo has been added
helm repo list
```

## Download Helm Charts from Nexus

```bash
# update repo metadata
helm repo update

# search repo
# "nexus/" will match all uploaded Helm charts
helm search repo nexus/

helm pull nexus/fluentd
helm pull nexus/jenkins
helm pull nexus/external-dns
```
