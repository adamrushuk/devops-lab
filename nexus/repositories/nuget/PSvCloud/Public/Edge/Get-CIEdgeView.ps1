function Get-CIEdgeView {
    <#
    .SYNOPSIS
    Gets the Edge View.

    .DESCRIPTION
    Gets the Edge View using the Search-Cloud cmdlet.

    .PARAMETER Name
    Specifies a single vShield Edge name.

    .INPUTS
    System.String

    .OUTPUTS
    VMware.VimAutomation.Cloud.Views.Gateway

    .EXAMPLE
    Get-CIEdgeView

    Returns all vShield Edges.

    .EXAMPLE
    Get-CIEdgeView -Name 'Edge01'

    Returns a single vShield Edge.

    .EXAMPLE
    Get-CIEdgeView -Name 'Edge01', 'Edge02'

    Returns multiple vShield Edges.

    .NOTES
    Author: Adam Rush
    #>
    [CmdletBinding()]
    [OutputType('VMware.VimAutomation.Cloud.Views.Gateway')]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]
        $Name
    )

    Begin {
        # Check for vcloud connection
        Test-CIConnection
    }

    Process {

        if ($PSBoundParameters.ContainsKey('Name')) {

            foreach ($EdgeName in $Name) {

                # Find Edge
                try {
                    Search-Cloud -QueryType EdgeGateway -Name $EdgeName | Get-CIView
                }
                catch [exception] {
                    Write-Error "An error occurred searching for Edge Gateway named $EdgeName."
                }

            } # End foreach

        }
        else {

            # Return all vShield Edges
            try {
                Search-Cloud -QueryType EdgeGateway | Get-CIView
            }
            catch [exception] {
                Write-Error "An error occurred searching for all Edge Gateways."
            }

        } # End if/else

    } # End process

} # End function
