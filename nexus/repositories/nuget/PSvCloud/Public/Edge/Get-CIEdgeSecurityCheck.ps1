function Get-CIEdgeSecurityCheck {
    <#
    .SYNOPSIS
    Retrieves basic security information for a vShield edge

    .DESCRIPTION
    Retrieves basic vShield edge security information including:
    - FW enabled (True/False)
    - FW default action (Allow/Drop)
    - Any insecure FW rules 

    .PARAMETER Name
    Specifies the name of the vShield Edge you want to retrieve.

    .PARAMETER CIEdge
    Specifies the PSCustomObject output of Get-CIEdge.

    .INPUTS
    System.Management.Automation.PSCustomObject

    .OUTPUTS
    System.Management.Automation.PSCustomObject

    .EXAMPLE
    Get-CIEdge | Get-CIEdgeSecurityCheck

    Returns firewall security information for the pipeline value of the Get-CIEdge command.

    .EXAMPLE
    Get-CIEdgeSecurityCheck -Name "Edge01"

    Returns firewall security information for the specified vShield edge.

    .EXAMPLE
    Get-CIEdgeSecurityCheck -Name 'Edge01', 'Edge02'

    Returns firewall security information for multiple vShield Edges.

    .NOTES
    Author: Matt Horgan
    #>
    [CmdletBinding(DefaultParameterSetName = "ByName")]
    [OutputType('System.Management.Automation.PSCustomObject')]
    param (

        [Parameter(Mandatory = $true, ParameterSetName = "ByName")]
        [ValidateNotNullOrEmpty()]
        [String[]]$Name,
        
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "Standard")]
        [ValidateNotNullOrEmpty()]
        $CIEdge

    )

    Begin {
        # Check for vcloud connection
        Test-CIConnection
    }

    Process {

        # If the parameter 'name' is specified, get CIEdge
        if ($PsCmdlet.ParameterSetName -eq "ByName") {

            $CIEdge = Get-CIEdge -Name $Name
            
        }
        
        # We need this foreach to handle multiple edges returned via 'name' parameter
        foreach ($Edge in $CIEdge) {
            # Check Firewall default action
            if ($Edge.XML.EdgeGateway.Configuration.EdgeGatewayServiceConfiguration.FirewallService.DefaultAction -ne "drop") {
                $FirewallDefaultAction = "Allow"
            }
            else {
                $FirewallDefaultAction = "Drop"
            }

            # Check Firewall is enabled/disabled
            if ($Edge.XML.EdgeGateway.Configuration.EdgeGatewayServiceConfiguration.FirewallService.IsEnabled -eq $false) {
                $FirewallEnabled = "False"
            }
            else {
                $FirewallEnabled = "True"
            }

            # Check for insecure firewall setups
            $AllowedEnabledRules = $Edge.XML.EdgeGateway.Configuration.EdgeGatewayServiceConfiguration.FirewallService.FirewallRule | 
                Where-Object {$_.IsEnabled -eq $true -and $_.Policy -eq "allow"}

            # Initialise array ready for PSCustomObject(s) of firewall rules 
            $InSecureFirewallRules = @()

            foreach ($Rule in $AllowedEnabledRules) {

                # Counter to ensure only offending rule(s) added to PSCustomObject
                $OffendingRuleCounter = $null

                switch ($Rule) {
                    {$Rule.SourceIp -eq "external" -and $Rule.DestinationIp -eq "external" -and $Rule.DestinationPortRange -eq "Any"} {  
                        $OffendingRuleCounter = $true
                        $RuleId = $Rule.Id
                        $RuleDescription = $Rule.Description 
                        $RuleViolation = "External to External on any port"
                        break
                    }
                    {$Rule.SourceIp -eq "external" -and $Rule.DestinationIp -eq "any" -and $Rule.DestinationPortRange -eq "Any"} {  
                        $OffendingRuleCounter = $true
                        $RuleId = $Rule.Id
                        $RuleDescription = $Rule.Description 
                        $RuleViolation = "External to Any on any port"
                        break
                    }
                    {$Rule.SourceIp -eq "external" -and $Rule.DestinationIp -eq "internal" -and $Rule.DestinationPortRange -eq "Any"} {  
                        $OffendingRuleCounter = $true
                        $RuleId = $Rule.Id
                        $RuleDescription = $Rule.Description 
                        $RuleViolation = "External to Internal on any port"
                        break
                    }
                    {$Rule.SourceIp -eq "any" -and $Rule.DestinationIp -eq "any" -and $Rule.DestinationPortRange -eq "Any"} {  
                        $OffendingRuleCounter = $true
                        $RuleId = $Rule.Id
                        $RuleDescription = $Rule.Description 
                        $RuleViolation = "Any to Any on any port"
                        break
                    }
                }
                
                # Build the offending rule PSCustomObject
                if ($OffendingRuleCounter) {
                    $InSecureFirewallRules += [PSCustomObject]@{
                        RuleId          = $RuleId
                        RuleDescription = $RuleDescription
                        RuleViolation   = $RuleViolation 
                        ExtensionData   = $Rule
                    }
                }
            }

            # Add default output for no offending rule
            if (!$InSecureFirewallRules) {
                $InSecureFirewallRules = "No offending rule(s)"
            }

            # Output to pipeline
            [PSCustomObject]@{
                Name                  = $Edge.Name
                FirewallEnabled       = $FirewallEnabled
                FirewallDefaultAction = $FirewallDefaultAction
                InsecureFirewallRules = $InSecureFirewallRules
            }
        }
    } # End process

} # End function