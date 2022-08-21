#!/usr/bin/env bash

# Steps from README to complete the initial lab setup

# Vars
DNS_RG_NAME="rg-dns"
LOCATION="eastus"
ROOT_DOMAIN_NAME="thehypepipe.co.uk"

# Configure DNS Zone
az group create --name "$DNS_RG_NAME" --location "$LOCATION"
az network dns zone create --resource-group "$DNS_RG_NAME" --name "$ROOT_DOMAIN_NAME"
