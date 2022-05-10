function Connect-ExchangeOnPremise {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        # Specifies an Exchange On-premise server hosting the PowerShell endpoint.
        [Parameter()]
        [string]$ExchangeServer,

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        # The CommandName parameter specifies the comma separated list of commands to import into the session. Use this parameter for applications or scripts that use a specific set of cmdlets. Reducing the number of cmdlets in the session helps improve performance and reduces the memory footprint of the application or script.
        [Parameter()]
        [ValidateNotNull()]
        [string[]]$CommandName = @('Get-DistributionGroup', 'Get-Recipient', 'New-DistributionGroup', 'Set-DistributionGroup', 'Update-DistributionGroupMember', 'Get-AcceptedDomain'),

        # Force reconnect to Exchange On-Premise
        [Parameter()]
        [switch]$Force
    )

    if (Get-Command -Name 'Get-EXCHMailbox' -ErrorAction SilentlyContinue) {
        return $true
    }
    else {
        try {
            if (-not $PSBoundParameters.ContainsKey('CommandName')) {
                [string[]]$CommandName = @('Get-DistributionGroup', 'Get-Recipient', 'New-DistributionGroup', 'Set-DistributionGroup', 'Update-DistributionGroupMember', 'Get-AcceptedDomain')
            }
            else {
                [string[]]$CommandName += 'Get-AcceptedDomain'
            }
            if ($PSBoundParameters.ContainsKey('Force')) {
                Remove-PSSession (Get-PSSession -ComputerName $ExchangeServer -ErrorAction SilentlyContinue -WarningAction SilentlyContinue) -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                $Module = Get-Module -Name 'tmp*'
                foreach ($Mod in $Module) {
                    if ((Get-Module ($Mod.ExportedCommands.Keys)) -match 'Add-EXCHAcceptedDomain') {
                        Remove-Module -Name $Mod.Name -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                    }
                }
            }
            $CurrentWarningPreference = $WarningPreference
            $WarningPreference = 'SilentlyContinue'
            $SessionParams = @{
                Name = 'EXCH'
                ConfigurationName = 'Microsoft.Exchange'
                ConnectionUri = "http://$($ExchangeServer)/PowerShell/?SerializationLevel=Full"
                Authentication = 'Kerberos'
                AllowRedirection = $true
                ErrorAction = 'Stop'
            }

            if ($Credential -ne [System.Management.Automation.PSCredential]::Empty) {
                $null = $SessionParams.Add('Credential', $Credential)
            }
            $Session = New-PSSession @SessionParams
            $null = Import-Module (Import-PSSession -Session $Session -Prefix EXCH -CommandName $CommandName -ErrorAction Stop -WarningAction SilentlyContinue -AllowClobber) -Prefix EXCH -Global -ErrorAction Stop
            return $true
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
        finally {
            $WarningPreference = $CurrentWarningPreference
        }
    }
}