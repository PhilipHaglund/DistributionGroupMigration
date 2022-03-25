function Connect-ExchangeOnline {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        # Specifies that no MFA will be used.
        [Parameter()]
        [switch]$NoMFA
    )

    if (Get-Command -Name 'Get-UnifiedGroup' -ErrorAction SilentlyContinue) {
        return $true
    }
    else {
        if ($NoMFA) {
            try {
                $CurrentWarningPreference = $WarningPreference
                $WarningPreference = 'SilentlyContinue'
                Connect-EXOLegacy
                if (Get-Command -Name 'Get-UnifiedGroup' -ErrorAction SilentlyContinue) {
                    return $true
                }
                else {
                    return $false
                }
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
            finally {
                $WarningPreference = $CurrentWarningPreference
            }
        }
        else {
            try {
                $CurrentWarningPreference = $WarningPreference
                $WarningPreference = 'SilentlyContinue'
                Connect-EXO
                if (Get-Command -Name 'Get-UnifiedGroup' -ErrorAction SilentlyContinue) {
                    return $true
                }
                else {
                    return $false
                }
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
            finally {
                $WarningPreference = $CurrentWarningPreference
            }
        }
    }
}