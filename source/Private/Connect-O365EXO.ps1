function Connect-O365EXO {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        # The CommandName parameter specifies the comma separated list of commands to import into the session. Use this parameter for applications or scripts that use a specific set of cmdlets. Reducing the number of cmdlets in the session helps improve performance and reduces the memory footprint of the application or script.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string[]]$CommandName = @('Get-DistributionGroup', 'Get-Recipient', 'New-DistributionGroup', 'Set-DistributionGroup', 'Update-DistributionGroupMember', 'Get-AcceptedDomain'),

        # The Prefix parameter specifies an alias to add to nouns in the names of older remote PowerShell cmdlets (cmdlet with nouns that don't already start with EXO). A valid value is a text string without spaces or special characters like underscrores, asterisks etc, and you can't use the value EXO (this prefix is reserved for PowerShell V2 module cmdlets).
        [Parameter()]
        [ValidatePattern('^(?!.*EXO).*$')]
        [string]$Prefix
    )

    try {
        $Module = 'ExchangeOnlineManagement'
        $Cmdlet = 'Get-EXOMailbox'
        $TestModule = Get-Module -Name $Module -ErrorAction Stop
        if (-not $TestModule) {
            Import-Module -Name $Module -ErrorAction Stop
        }
        if ((Get-Command -Name $Cmdlet -ErrorAction SilentlyContinue)) {
            $TestConnection = & $Cmdlet -Identity 'DiscoverySearchMailbox*' -ErrorAction Stop
            if ($TestConnection) {
                return $true
            }
            else {
                throw 'No connection to Exchange Online available.'
            }
        }
        else {
            throw ('The cmdlet "{0}" was not found in "{1}".' -f $Cmdlet,$Module)
        }
    }
    catch {
        try {
            $BoundParameters = @{
                ErrorAction = 'Stop'
                ShowBanner  = $false
            }
            if ($CommandName.Count -gt 0) {
                $BoundParameters.Add('CommandName', $CommandName)
            }
            if ($Prefix.Length -gt 0) {
                $BoundParameters.Add('Prefix', $Prefix)
            }
            $null = Connect-ExchangeOnline @BoundParameters
            return $true
        }
        catch {
            Write-PSFMessage -Level Warning -Message ('Unable to Connect-ExchangeOnline - {0}' -f $_.Exception.Message)
            return $false
        }
    }
}
