function Connect-ExchangeOnPremise {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        # Specifies an Exchange On-premise server hosting the PowerShell endpoint.
        [Parameter()]
        [string]$ExchangeServer
    )

    if (Get-Command -Name 'Get-EXCHMailbox' -ErrorAction SilentlyContinue) {
        return $true
    }
    else {
        try {
            $CurrentWarningPreference = $WarningPreference
            $WarningPreference = 'SilentlyContinue'
            $Session = New-PSSession -Name EXCH -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$($ExchangeServer)/PowerShell/" -Authentication Kerberos -AllowRedirection -ErrorAction Stop -WarningAction SilentlyContinue
            Import-Module (Import-PSSession -Session $Session -Prefix EXCH -ErrorAction Stop -WarningAction SilentlyContinue) -Prefix EXCH -Global -ErrorAction Stop -WarningAction SilentlyContinue
            return $true
        }
        catch {
            try {
                Write-PSFMessage -Level Warning -Message 'Unable to use Kerberos authentication for Exchange On-premise. Provide credentials to try again.'
                $Session = New-PSSession -Name EXCH -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$($ExchangeServer)/PowerShell/" -Credential (Get-Credential -Message 'Exchange On-premise credentials') -AllowRedirection -ErrorAction Stop -WarningAction SilentlyContinue
                Import-Module (Import-PSSession -Session $Session -Prefix EXCH -ErrorAction Stop -WarningAction SilentlyContinue) -Prefix EXCH -Global -ErrorAction Stop -WarningAction SilentlyContinue
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
        finally {
            $WarningPreference = $CurrentWarningPreference
        }
    }
}