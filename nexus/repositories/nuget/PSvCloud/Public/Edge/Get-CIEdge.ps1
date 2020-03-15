function Get-CIEdge {
    <#
    .SYNOPSIS
    Retrieves vCloud Edges.

    .DESCRIPTION
    Retrieves vCloud Edges, including View and XML configuration.

    .PARAMETER Name
    Specifies the name of the vShield Edge you want to retrieve.

    .INPUTS
    System.String

    .OUTPUTS
    System.Management.Automation.PSCustomObject

    .EXAMPLE
    Get-CIEdge

    Returns all vShield Edges.

    .EXAMPLE
    Get-CIEdge -Name 'Edge01'

    Returns a single vShield Edge.

    .EXAMPLE
    Get-CIEdge -Name 'Edge01', 'Edge02'

    Returns multiple vShield Edges.

    .NOTES
    Author: Adam Rush
    #>
    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCustomObject')]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Name
    )

    Begin {
        # Check for vcloud connection
        Test-CIConnection
    }

    Process {

        # Get CIViews
        $CIEdgeViewParams = @{}
        if ($PSBoundParameters.ContainsKey('Name')) {
            $CIEdgeViewParams.Name = $Name
        }

        try {
            $CIEdgeViews = Get-CIEdgeView @CIEdgeViewParams

            # Validation checks
            if ($CIEdgeViews.count -eq 0) {
                throw "No Edge Gateways were found."
            }
        }
        catch [exception] {
            Write-Error $_
            Continue
        }

        try {
            foreach ($CIEdgeView in $CIEdgeViews) {

                # Get Edge XML Configuration
                $CIEdgeXML = $CIEdgeView | Get-CIEdgeXML

                # Output to pipeline
                [PSCustomObject]@{
                    Name          = $CIEdgeView.Name
                    Href          = $CIEdgeView.Href
                    Id            = $CIEdgeView.Id
                    ExtensionData = $CIEdgeView
                    XML           = $CIEdgeXML
                }

            }
        }
        catch [exception] {
            throw $_
        }

    } # End process

} # End function
