function Test-CIConnection {
    <#
    .SYNOPSIS
    Tests for a connected vCloud session.

    .DESCRIPTION
    Tests for a single connected vCloud session.

    .PARAMETER DefaultCIServers
    All current vCloud connections from Global scope.

    .EXAMPLE
    Test-CIConnection

    .NOTES
    Author: Adam Rush
    #>
    [CmdletBinding()]
    param (
        $DefaultCIServers = $global:DefaultCIServers
    )

    # Must have only one vCloud connection open
    # Code snipet blatantly stolen from Vester :)
    if ($DefaultCIServers.Count -lt 1) {
        Write-Verbose -Message 'Please connect to vCloud before running this command.'
        throw 'A connection with Connect-CIServer is required'
    }
    elseif ($DefaultCIServers.Count -gt 1) {
        Write-Verbose 'Please connect to only one vCloud before running this command.'
        Write-Verbose "Current connections:  $($DefaultCIServers.Name -join ' / ')"
        throw 'Too many connections - A single connection with Connect-VIServer is required'
    }
    Write-Verbose "Current connections:  $($DefaultCIServers.Name -join ' / ')"
}
