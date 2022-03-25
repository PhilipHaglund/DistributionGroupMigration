function Remove-OnPremDSTGroup {
    <#
    .SYNOPSIS
    Remove one or more distribution groups in Exchange On-premise generated from Initialize-OnPremDSTGroupToCloud.

    .DESCRIPTION
    Remove-OnPremDSTGroup will remove the original distribution group in Exchange On-premise (also Active Directory) with data from Initialize-OnPremDSTGroupToCloud.
    Remove-OnPremDSTGroup requires that PSFClixml objects exist in the target LogPath location which is generated from Initialize-OnPremDSTGroupToCloud.
    The function Remove-OnPremDSTGroup goes through the following steps:

    1. Validate that the distribution group is exist in both Exchange Online and Exchange On-premises and that the property, "IsDirSynced", exist for the Exchange Online distribution group.
    2. Validate that the initialized distribution group is exist in Exchange Online.
    3. Remove the source distribution group from Exchange On-premise, which will also remove the Active Directory object.

    .EXAMPLE
    Remove-OnPremDSTGroup -Group 'dstgroup001@contoso.com' -ExchangeServer exchprod01.contoso.com

    [11:12:06][Remove-OnPremDSTGroup] Successfully removed the source distribution group with identity "dstgroup001@contoso.com" from Exchange On-premise.

    This example removes the source distribution group from Exchange On-premise, exchprod01.contoso.com, with the identity 'dstgroup001@contoso.com'.

    .EXAMPLE
    Remove-OnPremDSTGroup -Group 'dstgroup002@contoso.com' -ExchangeServer exchprod01.contoso.com -NoMFA

    [11:12:06][Remove-OnPremDSTGroup] Successfully removed the source distribution group with identity "dstgroup002@contoso.com" from Exchange On-premise.

    This example removes the source distribution group from Exchange On-premise, exchprod01.contoso.com, with the identity 'dstgroup002@contoso.com'.
    When NoMFA switch is issued the connection to Exchange Online PowerShell will be using the native experience instead of modern authentication.

    .EXAMPLE
    Remove-OnPremDSTGroup -Group 'dstgroup003@contoso.com' -ExchangeServer exchprod01.contoso.com -LogPath "C:\Log"

    [11:12:06][Remove-OnPremDSTGroup] Successfully removed the source distribution group with identity "dstgroup003@contoso.com" from Exchange On-premise.

    This example removes the source distribution group from Exchange On-premise, exchprod01.contoso.com, with the identity 'dstgroup003@contoso.com'.
    The LogPath parameter specifies an alternate path for all logs and the distribution group XML-objects.

    .EXAMPLE
    Remove-OnPremDSTGroup -Group 'dstgroup004@contoso.com' -ExchangeServer exchprod01.contoso.com -Force

    WARNING: [11:12:03][Remove-OnPremDSTGroup] Excluding validation of existence for the initialized distribution group.
    [11:12:06][Remove-OnPremDSTGroup] Successfully removed the source distribution group with identity "dstgroup004@contoso.com" from Exchange On-premise.

    This example removes the source distribution group from Exchange On-premise, exchprod01.contoso.com, with the identity 'dstgroup004@contoso.com'.
    The Force parameter will not connect to Exchange Online and validate the existence for the initialized distribution group.

    .LINK
    https://github.com/PhilipHaglund/DistributionGroupMigration/blob/master/docs/en-US/Remove-OnPremDSTGroup.md
    #>
    [CmdletBinding(
        SupportsShouldProcess
    )]
    param (
        # Specifies one or more distribution groups to be migrated. Recommended to use PrimarySmtpAddress as input to have a unique value.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [Alias('PrimarySmtpAddress')]
        [string[]]$Group,

        # Specifies an Exchange On-premise server hosting the PowerShell endpoint.
        [Parameter(
            Mandatory
        )]
        [Alias('EXCH')]
        [string]$ExchangeServer,

        <#
        Specifies the path for all logs and the distribution group XML-objects.
        Default the LogPath uses the 'PSFramework.Logging.FileSystem.LogPath' which defaults to "$env:APPDATA\WindowsPowerShell\PSFramework\Logs" for Windows PowerShell and
        "$env:APPDATA\PowerShell\PSFramework\Logs" for PowerShell Core.
        #>
        [Parameter()]
        [string]$LogPath = (Get-PSFConfigValue -FullName 'PSFramework.Logging.FileSystem.LogPath'),

        # Specifies that no validation will take place for the existence of the initialized distribution group before the distribution group removal.
        [Parameter()]
        [switch]$Force,

        # Specifies that No MFA will be used when connecting to Exchange Online. If the Force parameter is specified the NoMFA parameter will have no effect.
        [Parameter()]
        [switch]$NoMFA
    )
    begin {
        try {
            Set-PSFConfig -FullName 'PSFramework.Logging.FileSystem.LogPath' -Value $LogPath -ErrorAction Stop
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
        if (-not $PSBoundParameters.ContainsKey('Force')) {
            if ($PSCmdlet.ShouldProcess('Office365', 'Connect-ExchangeOnline')) {
                try {
                    $PreviousErrorActionPreference = $ErrorActionPreference
                    $ErrorActionPreference = 'Continue'
                    if (Connect-O365EXO -ErrorAction Stop -WarningAction SilentlyContinue) {
                        Write-PSFMessage -Level Verbose -Message 'Connected to Exchange Online.'
                    }
                    else {
                        throw [System.AccessViolationException]::New('Unable to establish a session to Exchange Online')
                    }
                }
                catch {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
                finally {
                    $ErrorActionPreference = $PreviousErrorActionPreference
                }
            }
        }
        if ($PSCmdlet.ShouldProcess($ExchangeServer, 'Connect-ExchangeOnPremise')) {
            try {
                $PreviousErrorActionPreference = $ErrorActionPreference
                $ErrorActionPreference = 'Continue'
                if (Connect-ExchangeOnPremise -ExchangeServer $ExchangeServer -ErrorAction Stop -WarningAction SilentlyContinue) {
                    Write-PSFMessage -Level Verbose -Message 'Connected to Exchange On-premise.'
                }
                else {
                    throw [System.AccessViolationException]::New('Unable to establish a session to Exchange On-Premise server {0}. Error: {1}' -f $ExchangeServer, $_.Exception)
                }
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
            finally {
                $ErrorActionPreference = $PreviousErrorActionPreference
            }
        }
    }
    process {
        :Group foreach ($GroupId in $Group) {
            if ($PSCmdlet.ShouldProcess($GroupId)) {
                try {

                    $DistributionGroupObject = Import-PSFClixml -Path "$LogPath\$GroupId.byte" -ErrorAction Stop

                    if (-not $PSBoundParameters.ContainsKey('Force')) {
                        $InitializedGroup = Get-DistributionGroup $DistributionGroupObject.InitializedGroup.PrimarySmtpAddress -ErrorAction Stop
                        if ($null -eq $InitializedGroup) {
                            Write-PSFMessage -Level Warning -Message ('Unable to find synchronized initialized distribution group {0} in Exchange Online. Will not continue with current group.' -f $GroupId)
                            continue
                        }
                        elseif ($InitializedGroup.Count -gt 1) {
                            Write-PSFMessage -Level Warning -Message ('More than one initialized distribution group found in Exchange Online with identity {0}. Will not continue with current group.' -f $GroupId)
                            continue
                        }
                    }

                    $ExchGroup = Get-ExchDistributionGroup -Identity $DistributionGroupObject.EXCH.PrimarySmtpAddress -ErrorAction Stop
                    if ($null -eq $ExchGroup) {
                        Write-PSFMessage -Level Warning -Message ('Unable to find distribution group {0} in Exchange On-premises. Will not continue with current group.' -f $GroupId) -WarningAction Continue
                        continue
                    }
                    elseif ($ExchGroup.Count -gt 1) {
                        Write-PSFMessage -Level Warning -Message ('More than one distribution group found in Exchange On-premises with identity {0}. Will not continue with current group.' -f $GroupId) -WarningAction Continue
                        continue
                    }

                    if ($PSBoundParameters.ContainsKey('Force') -or $PSCmdlet.ShouldContinue($ExchGroup.PrimarySmtpAddress, $MyInvocation.MyCommand.Name)) {
                        Remove-ExchDistributionGroup -Identity $ExchGroup.PrimarySmtpAddress -ErrorAction Stop -Confirm:$false
                        Write-PSFMessage -Level Host -Message ('Successfully removed the source distribution group with identity "{0}" from Exchange On-premise.' -f $DistributionGroupObject.EXCH.PrimarySmtpAddress)
                    }
                }
                catch {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            }
        }
    }
}