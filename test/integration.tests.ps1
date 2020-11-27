# Pester integration tests for provisioned infrastructure
# Assumes az cli has already been logged in

# Documentation:
# - https://pester.dev/docs/migrations/v3-to-v4#update-to-the-new-assertions-syntax
# - https://pester.dev/docs/usage/assertions

# Pester tests
Describe "Integration Tests" {

    # Terraform State Storage
    Context 'When Terraform has provisioned: [TERRAFORM STATE STORAGE]' {

        # [CI Param Option] Trigger failed test on purpose
        if ($env:FORCE_TEST_FAIL -eq "true") {
            It "FORCE_TEST_FAIL used on Resource Group [$env:AKS_RG_NAME]" {
                "false" | Should -Be "true"
            }
        }

        It "Resource Group [$env:TERRAFORM_STORAGE_RG] should exist" {
            az group exists --name $env:TERRAFORM_STORAGE_RG | Should -Be "true"
        }

        It "Storage Account [$env:TERRAFORM_STORAGE_ACCOUNT] should exist" {
            az storage account show --name $env:TERRAFORM_STORAGE_ACCOUNT --query "provisioningState" -o tsv | Should -Be "Succeeded"
        }

        It "Storage Blob [terraform.tfstate] in Container [terraform] should exist" {
            az storage blob exists --account-name $env:TERRAFORM_STORAGE_ACCOUNT --container-name "terraform" --name "terraform.tfstate" --query "exists" -o tsv | Should -Be "true"
        }
    }

    # Azure Kubernetes Service
    Context 'When Terraform has provisioned: [AZURE KUBERNETES SERVICE]' {

        It "Resource Group [$env:AKS_RG_NAME] should exist" {
            az group exists --name $env:AKS_RG_NAME | Should -Be "true"
        }

        It "Azure Kubernetes Service [$env:AKS_CLUSTER_NAME] should exist" {
            az aks show --name $env:AKS_CLUSTER_NAME --resource-group $env:AKS_RG_NAME --query "provisioningState" -o tsv | Should -Be "Succeeded"
        }
    }

    # DNS record updated
    Context "When DNS record has been updated for: [$env:DNS_DOMAIN_NAME]" {

        # Vars
        $testUrl = "https://$($env:DNS_DOMAIN_NAME)"
        $allowedStatusCodes = @(200, 304, 503)
        $expectedContent = "Nexus Repository Manager"

        # Request
        $invokeWebRequestParams = @{
            Uri                  = $testUrl
            # ignore certificate validation, as tested below
            SkipCertificateCheck = $true
        }
        $response = Invoke-WebRequest @invokeWebRequestParams

        # DEBUG Output
        if ($env:CI_DEBUG -eq "true") {
            $response | Format-List *
        }

        # Root domain
        It "A request to [$testUrl] should return an allowed Status Code: [$($allowedStatusCodes -join ', ')]" {
            # $responseStatusCode = curl -k -s -o /dev/null -w "%{http_code}" $testUrl
            $response.StatusCode | Should -BeIn $allowedStatusCodes
        }

        It "A request to [$testUrl] should include [$expectedContent] in the returned content" {
            # (curl -k -s $testUrl) -match $expectedContent | Should -Be $true
            $response.Content -match $expectedContent | Should -Be $true
        }
    }


    # SSL Certificate has been issued
    Context "When an SSL Certificate has been issued for: [$env:DNS_DOMAIN_NAME]" {

        # Vars
        $hostname = $env:DNS_DOMAIN_NAME
        $hostname = "nexus.thehypepipe.co.uk"
        $port = 443
        # Number of days out to warn about certificate expiration
        $warningThreshold = 14
        $expectedIssuerName = "Let's Encrypt Authority"

        # Get common cert info
        . ../scripts/Get-CertInfo.ps1
        $certResult = Get-CertInfo -ComputerName $hostname -Port $port

        # DEBUG Output
        if ($env:CI_DEBUG -eq "true") { $certResult | Format-Custom | Out-String | Write-Verbose }

        # Tests
        It "Should have an SSL cert for [$hostname] issued by: [$expectedIssuerName]" {
            $certResult.Issuer -like "*$expectedIssuerName*" | Should -Be $true
        }

        # Do extra supported tests if on Windows OS
        if ($IsWindows) {
            # Get cert
            . ../scripts/Test-SslProtocol.ps1
            $sslResult = Test-SslProtocol -ComputerName $hostname -Port $port

            # DEBUG Output
            if ($env:CI_DEBUG -eq "true") { $sslResult | Format-Custom | Out-String | Write-Verbose }

            It "Should have Signature Algorithm of [sha256RSA]" {
                $sslResult.SignatureAlgorithm | Should -Be "sha256RSA"
            }

            It "Should support TLS1.2" {
                $sslResult.TLS12 | Should -Be $True
            }

            It "Should not expire within [$warningThreshold] days" {
                ($sslResult.Certificate.NotAfter -gt (Get-Date).AddDays($warningThreshold)) | Should -Be $True
            }
        }
    }
}
