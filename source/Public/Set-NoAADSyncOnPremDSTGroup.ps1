function Set-NoAADSyncOnPremDSTGroup {
    <#
    .SYNOPSIS
    Set the 'adminDescription' property to 'Group_%PARAM%' for one or more distribution groups generated from Initialize-OnPremDSTGroupToCloud.

    .DESCRIPTION
    Set-NoAADSyncOnPremDSTGroup will set the 'adminDescription' property to 'Group_%PARAM%' so the target distribution group is excluded from the Azure AD Connect synchronization.
    Set-NoAADSyncOnPremDSTGroup requires that PSFClixml objects exist in the target LogPath location which is generated from Initialize-OnPremDSTGroupToCloud.
    The function Set-NoAADSyncOnPremDSTGroup goes through the following steps:

    1. Validate that the distribution group is exist in both Exchange Online and Exchange On-premises and that the property, "IsDirSynced", exist for the Exchange Online distribution group.
    2. Validate that the initialized distribution group is exist in Exchange Online.
    3. Set the 'adminDescription' property to 'Group_%PARAM%' for the target distribution group in Active Directory, which will remove the Exchange Online distribution group after the next AAD Connect sync cycle.

    Notice: The ActiveDirectory module is required for this function to work.

    .EXAMPLE
    Set-NoAADSyncOnPremDSTGroup -Group 'dstgroup001@contoso.com' -ExchangeServer exchprod01.contoso.com

    [11:12:06][Set-NoAADSyncOnPremDSTGroup] Successfully set the adminDescription property to "Group_NoAADSync" for the source distribution group "dstgroup001@contoso.com".

    This example sets the adminDescription property to 'Group_NoAADSync' for the target source distribution group "dstgroup001@contoso.com" using Active Directory.

    .EXAMPLE
    Set-NoAADSyncOnPremDSTGroup -Group 'dstgroup002@contoso.com' -ExchangeServer exchprod01.contoso.com -NoMFA

    [11:12:06][Set-NoAADSyncOnPremDSTGroup] Successfully set the adminDescription property to "Group_NoAADSync" for the source distribution group "dstgroup002@contoso.com".

    This example sets the adminDescription property to 'Group_NoAADSync' for the target source distribution group "dstgroup001@contoso.com" using Active Directory.
    When NoMFA switch is issued the connection to Exchange Online PowerShell will be using the native experience instead of modern authentication.

    .EXAMPLE
    Set-NoAADSyncOnPremDSTGroup -Group 'dstgroup003@contoso.com' -ExchangeServer exchprod01.contoso.com -LogPath "C:\Log"

    [11:12:06][Set-NoAADSyncOnPremDSTGroup] Successfully set the adminDescription property to "Group_NoAADSync" for the source distribution group "dstgroup003@contoso.com".

    This example sets the adminDescription property to 'Group_NoAADSync' for the target source distribution group "dstgroup001@contoso.com" using Active Directory.
    The LogPath parameter specifies an alternate path for all logs and the distribution group XML-objects.

    .EXAMPLE
    Set-NoAADSyncOnPremDSTGroup -Group 'dstgroup004@contoso.com' -ExchangeServer exchprod01.contoso.com -Suffix 'NoO365Sync'

    [11:12:06][Set-NoAADSyncOnPremDSTGroup] Successfully set the adminDescription property to "Group_NoO365Sync" for the source distribution group "dstgroup004@contoso.com".

    This example sets the adminDescription property to 'Group_NoAADSync' for the target source distribution group "dstgroup001@contoso.com" using Active Directory.
    The Suffix parameter specifies an alternate suffix for to put in the adminDescription property.

    .EXAMPLE
    Set-NoAADSyncOnPremDSTGroup -Group 'dstgroup005@contoso.com' -ExchangeServer exchprod01.contoso.com -Force

    WARNING: [11:12:03][Set-NoAADSyncOnPremDSTGroup] Excluding validation of existence for the initialized distribution group.
    [11:12:06][Set-NoAADSyncOnPremDSTGroup] Successfully set the adminDescription property to "Group_NoAADSync" for the source distribution group "dstgroup005@contoso.com".

    This example removes the source distribution group from Exchange On-premise, exchprod01.contoso.com, with the identity 'dstgroup004@contoso.com'.
    The Force parameter will not connect to Exchange Online and validate the existence for the initialized distribution group.

    .LINK
    https://github.com/PhilipHaglund/DistributionGroupMigration/blob/master/docs/en-US/Set-NoAADSyncOnPremDSTGroup.md
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

        # Specifies the suffix for the property adminDescription. Default the suffix is 'NoAADSync'. The string will concatenate the [string]'Group_' with $Suffix.
        [Parameter()]
        [string]$Suffix = 'NoAADSync',

        # Specifies that No MFA will be used when connecting to Exchange Online. If the Force parameter is specified the NoMFA parameter will have no effect.
        [Parameter()]
        [switch]$NoMFA
    )
    begin {
        try {
            Import-Module -Name ActiveDirectory -Force -ErrorAction Stop -WarningAction Stop
        }
        catch {
            Write-PSFMessage -Level Critical -Message ('The ActiveDirectory module is not installed. {1} will not continue.' -f $env:COMPUTERNAME, 'Set-NoAADSyncOnPremDSTGroup')
            $PSCmdlet.ThrowTerminatingError($_)
        }
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
        $AdminDescription = "Group_$Suffix"
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

                    $ADGroup = Get-ADGroup -Identity $DistributionGroupObject.EXCH.DistinguishedName -ErrorAction Stop
                    Set-ADGroup -Identity $ADGroup.DistinguishedName -Replace @{'adminDescription' = $AdminDescription } -ErrorAction Stop
                    Write-PSFMessage -Level Host -Message ('Successfully set the adminDescription property to "{0}" for the source distribution group "dstgroup001@contoso.com". {0}.' -f $AdminDescription, $DistributionGroupObject.EXCH.PrimarySmtpAddress)
                }
                catch {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            }
        }
    }
}