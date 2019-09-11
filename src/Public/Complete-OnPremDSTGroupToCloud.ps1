function Complete-OnPremDSTGroupToCloud {
    <#
    .SYNOPSIS
    Completes a migration of one or more synchronized (Azure AD Connect) distribution groups in Exchange Online generated from Initialize-OnPremDSTGroupToCloud.

    .DESCRIPTION
    Complete-OnPremDSTGroupToCloud will rename and remove the prefix from the distribution group created from Initialize-OnPremDSTGroupToCloud.
    Complete-OnPremDSTGroupToCloud requires that PSFClixml objects exist in the target LogPath location which is generated from Initialize-OnPremDSTGroupToCloud.
    The function Complete-OnPremDSTGroupToCloud goes through the following steps:

    1. Validate that the initialized distribution group is exist in Exchange Online.
    2. Validate that the old synchronized distribution does not exist in Exchange Online.
    3. Remove the prefix from all properties on the initialized distribution group in Exchange Online.

    The following properties will have the prefix removed for the initialized distribution group:
    "Alias", "DisplayName", "Name", "PrimarySmtpAddress", "EmailAddresses"

    .EXAMPLE
    Complete-OnPremDSTGroupToCloud -Group 'dstgroup001@contoso.com'

    [11:12:06][Complete-OnPremDSTGroupToCloud] Successfully removed the prefix from all properties on "dstgroup001@contoso.com".
    [11:12:06][Complete-OnPremDSTGroupToCloud] Exported a PSFClixml object of the distribution group, before and after completion, to "C:\Users\UserName\AppData\Roaming\WindowsPowerShell\PSFramework\Logs".

    This example retrieves the exported initialized distribution group object from the default path and removes the prefix.

    .EXAMPLE
    Complete-OnPremDSTGroupToCloud -Group 'dstgroup002@contoso.com' -LogPath "C:\Log"

    [11:12:06][Complete-OnPremDSTGroupToCloud] Successfully removed the prefix from all properties on "dstgroup002@contoso.com".
    [11:12:06][Complete-OnPremDSTGroupToCloud] Exported a PSFClixml object of the distribution group, before and after completion, to "C:\Log".

    This example retrieves the exported initialized distribution group object from the defined path "C:\Log" and removes the prefix.
    The LogPath parameter specifies an alternate path for where all logs and the distribution group XML-objects is created from Initialize-OnPremDSTGroupToCloud.

    .EXAMPLE
    Complete-OnPremDSTGroupToCloud -Group 'dstgroup003@contoso.com' -NoMFA

    [11:12:06][Complete-OnPremDSTGroupToCloud] Successfully removed the prefix from all properties on "dstgroup003@contoso.com".
    [11:12:06][Complete-OnPremDSTGroupToCloud] Exported a PSFClixml object of the distribution group, before and after completion, to "C:\Users\UserName\AppData\Roaming\WindowsPowerShell\PSFramework\Logs".

    This example retrieves the exported initialized distribution group object from the default path and removes the prefix.
    When NoMFA switch is issued the connection to Exchange Online PowerShell will be using the native experience instead of modern authentication.

    .LINK
    https://github.com/PhilipHaglund/DistributionGroupMigration/blob/master/docs/en-US/Complete-OnPremDSTGroupToCloud.md
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

        <#
        Specifies the path for all logs and the distribution group XML-objects.
        Default the LogPath uses the 'PSFramework.Logging.FileSystem.LogPath' which defaults to "$env:APPDATA\WindowsPowerShell\PSFramework\Logs" for Windows PowerShell and
        "$env:APPDATA\PowerShell\PSFramework\Logs" for PowerShell Core.
        #>
        [Parameter()]
        [string]$LogPath = (Get-PSFConfigValue -FullName 'PSFramework.Logging.FileSystem.LogPath'),

        # Specifies that No MFA will be used when connecting to Exchange Online.
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
        if ($PSCmdlet.ShouldProcess('Office365', 'Connect-ExchangeOnline')) {
            try {
                $PreviousErrorActionPreference = $ErrorActionPreference
                $ErrorActionPreference = 'Continue'
                if (Connect-ExchangeOnline -NoMFA:$NoMFA -ErrorAction Stop -WarningAction SilentlyContinue) {
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

        [regex]$PrefixAttribute = 'Alias|DisplayName|Name|PrimarySmtpAddress'
    }
    process {
        :Group foreach ($GroupId in $Group) {
            if ($PSCmdlet.ShouldProcess($GroupId)) {
                try {
                    $ExoGroup = $null
                    $DistributionGroupObject = [PSCustomObject]@{
                        'EXO'              = $null
                        'EXCH'             = $null
                        'Manager'          = $null
                        'Members'          = $null
                        'InitializedGroup' = $null
                        'CompletedGroup'   = $null
                        'Prefix'           = $null
                    }

                    $DistributionGroupObject = Import-PSFClixml -Path "$LogPath\$GroupId.byte" -ErrorAction Stop

                    try {
                        $ExoGroup = Get-DistributionGroup -Identity $DistributionGroupObject.EXO.PrimarySmtpAddress -ErrorAction Stop
                        if ($null -ne $ExoGroup) {
                            Write-PSFMessage -Level Warning -Message ('The original synchronized distribution group {0} still exist in Exchange Online. Will not continue with current group.' -f $GroupId)
                            continue
                        }
                        elseif ($ExoGroup.Count -gt 1) {
                            Write-PSFMessage -Level Warning -Message ('More than one distribution group found in Exchange Online with identity {0}. Will not continue with current group.' -f $GroupId)
                            continue
                        }
                    }
                    catch {
                        Write-PSFMessage -Level Verbose -Message ('Original synchronized distribution group is correctly removed from Exchange Online.' -f $GroupId)
                    }

                    $InitializedGroup = Get-DistributionGroup $DistributionGroupObject.InitializedGroup.PrimarySmtpAddress -ErrorAction Stop
                    if ($null -eq $InitializedGroup) {
                        Write-PSFMessage -Level Warning -Message ('Unable to find synchronized initialized distribution group {0} in Exchange Online. Will not continue with current group.' -f $GroupId)
                        continue
                    }
                    elseif ($InitializedGroup.Count -gt 1) {
                        Write-PSFMessage -Level Warning -Message ('More than one initialized distribution group found in Exchange Online with identity {0}. Will not continue with current group.' -f $GroupId)
                        continue
                    }

                    Write-PSFMessage -Level Host -Message ('Successfully retrieved the initialized distribution group with identity "{0}".' -f $InitializedGroup.PrimarySmtpAddress)

                    $Command = Get-Command -Name Set-DistributionGroup -ErrorAction Stop
                    [hashtable]$InitializeSetGroup = @{ }

                    foreach ($Parameter in ($Command.Parameters.GetEnumerator() | Sort-Object)) {
                        if ($Parameter.Key -match $PrefixAttribute) {
                            Write-PSFMessage -Level Verbose -Message ('Removing prefix "{0}" for property {0}.' -f $DistributionGroupObject.Prefix, $Parameter.Key)
                            $InitializeSetGroup.Add("$($Parameter.Key)", ($DistributionGroupObject.InitializedGroup."$($Parameter.Key)" -replace $DistributionGroupObject.Prefix))
                        }
                        elseif ($Parameter.Key -match 'HiddenFromAddressListsEnabled') {
                            $HiddenFromAddressListsEnabled = switch ($DistributionGroupObject.EXO.HiddenFromAddressListsEnabled) {
                                $true { $true }
                                $false { $false }
                                default { $true }
                            }
                        }
                    }
                    $EmailAddresses = foreach ($Address in $DistributionGroupObject.InitializedGroup.EmailAddresses) {
                        if ($Address -match '^smtp\:') {
                            $Address -replace ('^(smtp\:){0}(.+)' -f $DistributionGroupObject.Prefix), '$1$2'
                        }
                    }

                    Write-PSFMessage -Level Verbose -Message ('Updating distribution group {0}.' -f $DistributionGroupObject.InitializedGroup.PrimarySmtpAddress)
                    Set-DistributionGroup -Identity $DistributionGroupObject.InitializedGroup.PrimarySmtpAddress @InitializeSetGroup -HiddenFromAddressListsEnabled:$HiddenFromAddressListsEnabled -ErrorAction Stop
                    Set-DistributionGroup -Identity $InitializeSetGroup['PrimarySmtpAddress'] -EmailAddresses $EmailAddresses -ErrorAction Stop
                    $CompletedGroup = Get-DistributionGroup -Identity $InitializeSetGroup['PrimarySmtpAddress'] -ErrorAction Stop
                    Write-PSFMessage -Level Host -Message ('Successfully removed the prefix from all properties on  {0}.' -f $InitializeSetGroup['PrimarySmtpAddress'])

                    $DistributionGroupObject | Add-Member -MemberType NoteProperty -Name CompletedGroup -Value $CompletedGroup -Force -ErrorAction Stop
                    $DistributionGroupObject | Export-PSFClixml -Path "$LogPath\Completed_$GroupId.byte" -Depth 5 -ErrorAction Stop
                    Write-PSFMessage -Level Host -Message ('Exported a PSFClixml object of the distribution group, before and after completion, to "{0}".' -f "$LogPath\Completed_$GroupId.byte")
                    Write-PSFMessage -Level Verbose -Message ('Use Import-PFClixml -Path "{0}" to view the content.' -f "$LogPath\Completed_$GroupId.byte")
                }
                catch {
                    if ($DistributionGroupObject) {
                        $DistributionGroupObject | Export-PSFClixml -Path "$LogPath\$GroupId.byte" -Depth 5 -ErrorAction Stop
                        Write-PSFMessage -Level Critical -Message ('Error occurred, will export current configuration of all distribution groups collected and its properties to a PSFClixml object to {0}.' -f "$LogPath\$GroupId.byte")
                        Write-PSFMessage -Level Verbose -Message ('Use Import-PFClixml -Path "{0}" to view the content.' -f "$LogPath\$GroupId.byte")
                    }
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            }
        }
    }
}