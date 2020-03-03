# Gets cert info
#
# Source: https://isc.sans.edu/forums/diary/Assessing+Remote+Certificates+with+Powershell/20645/
# CertInfo.ps1
#
# Written by: Rob VandenBrink
#
# Params: Site name or IP ($ComputerName), Port ($Port)
function Get-CertInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        $ComputerName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [int]$Port = 443
    )

    try {
        $conn = New-Object System.Net.Sockets.TcpClient($ComputerName, $Port)
        try {
            $stream = New-Object System.Net.Security.SslStream($conn.GetStream(), $false, {
                    param($sender, $certificate, $chain, $sslPolicyErrors)
                    return $true
                })
            $stream.AuthenticateAsClient($ComputerName)

            $cert = $stream.Get_RemoteCertificate()
            # $CN = (($cert.Subject -split "=")[1] -split ",")[0]
            $cert
        } catch { throw $_ }
        finally { $conn.close() }
    } catch {
        Write-Host "$ID $ComputerName " $_.exception.innerexception.message -ForegroundColor red
    }
}

Write-Verbose "LOADED: Get-CertInfo.ps1"
