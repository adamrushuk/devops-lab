# Nexus API Example
# https://nexus.thehypepipe.co.uk/#admin/system/api

# Vars
$username = 'admin'
$password = '<NEXUS_ADMIN_PASSWORD>'
$ServerUri = "https://nexus.thehypepipe.co.uk"
$baseUri = "$ServerUri/service/rest"


# GET example with authorization header
$bytes = [System.Text.Encoding]::UTF8.GetBytes("$username`:$password")
$cred = [System.Convert]::ToBase64String($bytes)

$restParams = @{
    Uri     = "$baseUri/v1/security/users"
    Method  = "GET"
    Headers = @{
        authorization = "Basic $cred"
        accept        = "application/json"
    }
}
Invoke-RestMethod @restParams


# GET examples with credential
$credential = [pscredential]::new($username, (ConvertTo-SecureString -String $password -AsPlainText -Force))

# Endpoints
$endpoint = "$baseUri/v1/security/users"
$endpoint = "$baseUri/v1/repositories"
$endpoint = "$baseUri/v1/security/realms/active"
$endpoint = "$baseUri/v1/security/realms/available"

$restParams = @{
    Uri            = $endpoint
    Method         = "GET"
    Headers        = @{
        accept = "application/json"
    }
    Authentication = "Basic"
    Credential     = $credential
}
Invoke-RestMethod @restParams


# PUT example
$body = @{
    enabled   = "true"
    userId    = "anonymous"
    realmName = "NexusAuthorizingRealm"
}

$restParams = @{
    Uri            = "$baseUri/internal/ui/anonymous-settings"
    Method         = "PUT"
    Headers        = @{
        authorization = "Basic $cred"
        accept        = "application/json"
    }
    ContentType    = "application/json"
    Authentication = "Basic"
    Credential     = [pscredential]::new($username, (ConvertTo-SecureString -String $password -AsPlainText -Force))
    Body           = ($body | ConvertTo-Json)
}
Invoke-RestMethod @restParams -Verbose
