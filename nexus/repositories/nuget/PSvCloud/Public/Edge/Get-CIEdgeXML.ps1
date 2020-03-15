function Get-CIEdgeXML {
    <#
    .SYNOPSIS
    Gets the vCloud Edge configuration XML.

    .DESCRIPTION
    Gets the vCloud Edge configuration XML using the REST API.

    .PARAMETER CIEdgeView
    CIEdgeView object for SessionKey and Name properties.

    .INPUTS
    VMware.VimAutomation.Cloud.Views.Gateway

    .OUTPUTS
    System.Xml.XmlDocument

    .EXAMPLE
    Get-CIEdgeXML -CIEdgeView $CIEdgeView

    .EXAMPLE
    $CIEdgeView | Get-CIEdgeXML

    .NOTES
    Author: Adam Rush
    #>
    [CmdletBinding()]
    [OutputType('System.Xml.XmlDocument')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [VMware.VimAutomation.Cloud.Views.Gateway]
        $CIEdgeView
    )

    # Get Edge XML
    try {
        # Set headers
        $Headers = @{
            "x-vcloud-authorization" = $CIEdgeView.Client.SessionKey
            "Accept"                 = "application/*+xml;version=5.1"
        }

        # Get Edge Configuration in XML format
        $Uri = $CIEdgeView.href
        [XML]$EdgeXML = Invoke-RestMethod -URI $Uri -Method GET -Headers $Headers
        Write-Output $EdgeXML
    }
    catch [exception] {
        throw "Could not get configuration XML for $($CIEdgeView.Name)."
    }

}
