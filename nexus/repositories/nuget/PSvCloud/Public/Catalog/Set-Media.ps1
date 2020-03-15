function Set-Media {
    <#
        .SYNOPSIS
        Ejects from and Inserts media into vCloud VMs.

        .DESCRIPTION
        Ejects from and Inserts media into vCloud VMs.

        .PARAMETER Name
        Specifies the media name.

        .PARAMETER CIVMName
        Specifies the vCloud VM name.

        .PARAMETER NoMedia
        Indicates that you want to detach the connected media - ISO from datastore or host device.

        .INPUTS
        System.String

        .OUTPUTS
        PSCustomObject

        .EXAMPLE
        Set-Media -Name 'Media01' -CIVMName 'VM01'

        Inserts media named 'Media01' into the vCloud VM named 'VM01'.

        .EXAMPLE
        Set-Media -Name 'Media01' -CIVMName 'VM01' -NoMedia

        Ejects media named 'Media01' from the vCloud VM named 'VM01'.

        .NOTES
        Author: Adam Rush
        GitHub: adamrushuk
        Twitter: @adamrushuk
    #>
    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCustomObject')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $CIVMName,

        [Parameter(Mandatory = $false)]
        [switch]
        $NoMedia
    )

    Begin {}

    Process {

        try {

            # Record start time
            $StartTime = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")

            # Get media
            Write-Verbose -Message "Finding media with name: $($Name)"
            $Media = Get-Media -Name $Name

            # Must have only one media item
            if ($Media.Count -lt 1) {
                throw "No media was found with name: $($Name)"
            }
            elseif ($Media.Count -gt 1) {
                throw "More than one media item was found with name: $($Name)"
            }

            # Get CIVM
            Write-Verbose -Message "Finding VM with name: $($CIVMName)"
            $CIVM = Get-CIVM -Name $CIVMName

            # Must have only one CIVM item
            if ($CIVM.Count -lt 1) {
                throw "No VM was found with name: $($CIVMName)"
            }
            elseif ($CIVM.Count -gt 1) {
                throw "More than one VM was found with name: $($CIVMName)"
            }

            # Build Media object to pass to eject/insert methods
            [VMware.VimAutomation.Cloud.Views.Reference] $MediaViewRef = @{
                Href            = $Media.ExtensionData.Href
                Id              = $Media.ExtensionData.Id
                Type            = $Media.ExtensionData.Type
                Name            = $Media.ExtensionData.Name
                AnyAttr         = $Media.ExtensionData.AnyAttr
                VCloudExtension = $Media.ExtensionData.VCloudExtension
            }

            # Build output
            $Action = ''

            if ($PSBoundParameters.ContainsKey('NoMedia')){

                # Eject media
                Write-Verbose -Message "Ejecting media: $($Name) for VM: $($CIVMName)"
                $CIVM.ExtensionData.EjectMedia($MediaViewRef)

                # Set action
                $Action = 'EjectMedia'

            } else {

                # Insert media
                Write-Verbose -Message "Inserting media: $($Name) for VM: $($CIVMName)"
                $CIVM.ExtensionData.InsertMedia($MediaViewRef)

                # Set action
                $Action = 'InsertMedia'

            }

            # Output info
            [PSCustomObject] @{
                StartTime = $StartTime
                StopTime = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
                Action = $Action
                Name = $Name
                CIVMName = $CIVMName
            }

        }
        catch [exception] {

            throw $_

        }

    } # End process

} # End function
