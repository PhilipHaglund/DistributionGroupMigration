function Initialize-OnPremDSTGroupToCloud {
    <#
    .SYNOPSIS
    Creates a copy of one or more synchronized (Azure AD Connect) distribution groups in Exchange Online with a defined prefix.

    .DESCRIPTION
    Initialize-OnPremDSTGroupToCloud will create a copy of one or more synchronized (Azure AD Connect) distribution groups in Exchange Online with a defined prefix, default 'PreMig-.
    The function Initialize-OnPremDSTGroupToCloud goes through the following steps:

    1. Validate that the distribution group is exist in both Exchange Online and Exchange On-premises and that the property, "IsDirSynced", exist for the Exchange Online distribution group.
    2. Validate Members of the distribution group. If the Members object is not existing in Exchange Online as a valid mail recipient the function will hard fail unless the force parameter is used.
    3. Validate ManagedBy of the distribution group. If the ManagedBy object is not an existing in Exchange Online as a valid mail recipient the function will hard fail unless the force parameter is used.
    4. Creates a copy of the synchronized distribution group in Exchange Online with a defined prefix on all properties that must remain unique.

    The following properties will receive the prefix for the created distribution group:
    "Alias", "DisplayName", "Name", "PrimarySmtpAddress", "EmailAddresses"

    .EXAMPLE
    Initialize-OnPremDSTGroupToCloud -Group 'dstgroup001@contoso.com' -ExchangeServer exchprod01.contoso.com

    [11:12:06][Initialize-OnPremDSTGroupToCloud] Successfully created a cloud only distribution group with identity "PreMig-dstgroup001@contoso.com".
    [11:12:06][Initialize-OnPremDSTGroupToCloud] Exported a PSFClixml object of the distribution group, before and after initialization, to "C:\Users\UserName\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\dstgroup001@contoso.com.byte".

    This example creates a "Cloud Only" (Exchange Online) copy of the Exchange On-premise distribution group 'dstgroup001@contoso.com' with the prefix 'PreMig-'.

    .EXAMPLE
    Initialize-OnPremDSTGroupToCloud -Group 'dstgroup002@contoso.com' -ExchangeServer exchprod01.contoso.com -Prefix 'Mig1234-'

    [11:12:06][Initialize-OnPremDSTGroupToCloud] Successfully created a cloud only distribution group with identity "Mig1234-dstgroup002@contoso.com".
    [11:12:06][Initialize-OnPremDSTGroupToCloud] Exported a PSFClixml object of the distribution group, before and after initialization, to "C:\Users\UserName\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\dstgroup002@contoso.com.byte".

    This example creates a "Cloud Only" (Exchange Online) copy of the Exchange On-premise distribution group 'dstgroup001@contoso.com' with the prefix 'Mig1234-'.

    .EXAMPLE
    Initialize-OnPremDSTGroupToCloud -Group 'dstgroup003@contoso.com' -ExchangeServer exchprod01.contoso.com -Force

    WARNING: [11:12:03][Initialize-OnPremDSTGroupToCloud] Excluding manager Administrator@contoso.local for group dstgroup003@contoso.com because recipient does not exist in Exchange Online as a valid recipient.
    WARNING: [11:12:03][Initialize-OnPremDSTGroupToCloud] Excluding member  Administrator@contoso.local for group dstgroup003@contoso.com because recipient does not exist in Exchange Online as a valid recipient.

    [11:12:06][Initialize-OnPremDSTGroupToCloud] Successfully created a cloud only distribution group with identity "PreMig-dstgroup003@contoso.com".
    [11:12:06][Initialize-OnPremDSTGroupToCloud] Exported a PSFClixml object of the distribution group, before and after initialization, to "C:\Users\UserName\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\dstgroup003@contoso.com.byte".

    This example creates a "Cloud Only" (Exchange Online) copy of the Exchange On-premise distribution group 'dstgroup001@contoso.com' with the prefix 'PreMig-'.
    If any member of the Members property or and manager of the ManagedBy property does not exist as a valid mail recipient in Exchange Online,
    that member or manager will be excluded from the created distribution group in Exchange Online.

    .EXAMPLE
    Initialize-OnPremDSTGroupToCloud -Group 'dstgroup004@contoso.com' -ExchangeServer exchprod01.contoso.com

    [11:12:06][Initialize-OnPremDSTGroupToCloud] Successfully created a cloud only distribution group with identity "PreMig-dstgroup004@contoso.com".
    [11:12:06][Initialize-OnPremDSTGroupToCloud] Exported a PSFClixml object of the distribution group, before and after initialization, to "C:\Users\UserName\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\dstgroup004@contoso.com.byte".

    This example creates a "Cloud Only" (Exchange Online) copy of the Exchange On-premise distribution group 'dstgroup001@contoso.com' with the prefix 'Mig1234-'.

    .EXAMPLE
    Initialize-OnPremDSTGroupToCloud -Group 'dstgroup005@contoso.com' -ExchangeServer exchprod01.contoso.com -LogPath "C:\Log"

    [11:12:06][Initialize-OnPremDSTGroupToCloud] Successfully created a cloud only distribution group with identity "PreMig-dstgroup005@contoso.com".
    [11:12:06][Initialize-OnPremDSTGroupToCloud] Exported a PSFClixml object of the distribution group, before and after initialization, to "C:\Log\dstgroup005@contoso.com.byte".

    This example creates a "Cloud Only" (Exchange Online) copy of the Exchange On-premise distribution group 'dstgroup005@contoso.com' with the prefix 'PreMig-'.
    The LogPath parameter specifies an alternate path for all logs and the distribution group XML-objects.

    .LINK
    https://github.com/PhilipHaglund/DistributionGroupMigration/blob/master/docs/en-US/Initialize-OnPremDSTGroupToCloud.md
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
        Specifies a prefix to be used when creating a duplicate distribution group. Default value 'PreMig-'
        To avoid already existing prefixes use a prefix which is unique.
        Validation will occur against the regular expression "^[a-z0-9]{4,9}\-".
        "a-z" a single character in the range between a and z (case insensitive)
        "0-9" a single character in the range between 0 and 9 (case insensitive)
        "{4,9}" Matches between 4 and 9 times, as many times as possible
        "\-"" matches the character - literally (case insensitive)
        #>
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-z0-9]{4,9}\-')]
        [string]$Prefix = 'PreMig-',

        # Specifies that managers and members of a distribution group will be removed from the distribution group if they don't are eligible to be a manager or member of a cloud only distribution group.
        [Parameter()]
        [switch]$Force,

        <#
        The Manager parameter specifies an owner for the group. A group must have at least one owner. If you don't use this parameter to specify the owner when you migrate the group, the existing manager for the On-Premise group is used. If the On-Premise Manager is unresolvable in Exchange Online (missing or not synced) the Initialize-OnPremDSTGroupToCloud won't create a copy of the Distribution Group in Exchange Online.
        The owner you specify for this parameter must be a mailbox, mail user or mail-enabled security group (a mail-enabled security principal that can have permissions assigned). You can use any value that uniquely identifies the owner. For example:

        - User principal name (UPN) or E-Mail Address.

        To enter multiple owners and overwrite all existing entries, use the following syntax: `Owner1,Owner2,...OwnerN`.
        An owner that you specify with this parameter isn't automatically a member of the group. You need to manually add the owner as a member.
        #>
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Net.Mail.MailAddress[]]$Manager,

        <#
        Specifies the path for all logs and the distribution group XML-objects.
        Default the LogPath uses the 'PSFramework.Logging.FileSystem.LogPath' which defaults to "$env:APPDATA\WindowsPowerShell\PSFramework\Logs" for Windows PowerShell and
        "$env:APPDATA\PowerShell\PSFramework\Logs" for PowerShell Core.
        #>
        [Parameter()]
        [string]$LogPath = (Get-PSFConfigValue -FullName 'PSFramework.Logging.FileSystem.LogPath')
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
        if ($PSCmdlet.ShouldProcess('Get-AcceptedDomain')) {
            try {
                $AcceptedDomain = Get-AcceptedDomain -ErrorAction Stop
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
        [array]$ValidRecipientTypeDetails = @('UserMailbox', 'LegacyMailbox' , 'SharedMailbox' , 'TeamMailbox' , 'MailUser' , 'LinkedMailbox' , 'RemoteUserMailbox' , 'RemoteSharedMailbox', 'RemoteTeamMailbox', 'MailContact', 'User', 'UniversalSecurityGroup', 'MailUniversalSecurityGroup')
        [regex]$ExcludeNew = 'ManagedBy|OrganizationalUnit'
        [regex]$ExcludeSet = 'ManagedBy|OrganizationalUnit|Alias|DisplayName|Name|PrimarySmtpAddress|Identity|WindowsEmailAddress|UMDtmfMap|HiddenFromAddressListsEnabled'
        [regex]$AddPrefix = 'Alias|DisplayName|Name|PrimarySmtpAddress'
    }
    process {
        :Group foreach ($GroupId in $Group) {
            if ($PSCmdlet.ShouldProcess($GroupId)) {
                try {
                    $ExoGroup = $null
                    $ExchGroup = $null
                    $ManagerId = $null
                    $OnlineManagerId = $null
                    $Members = $null
                    $Member = $null
                    $OnlineMemberId = $null
                    $ManagedBy = $null
                    [Collections.ArrayList]$ValidManagers = [Collections.ArrayList]::new()
                    [Collections.ArrayList]$ValidMembers = [Collections.ArrayList]::new()
                    $DistributionGroupObject = [PSCustomObject]@{
                        'EXO'              = $null
                        'EXCH'             = $null
                        'Manager'          = $null
                        'Members'          = $null
                        'InitializedGroup' = $null
                        'Prefix'           = $Prefix
                    }

                    $ExoGroup = Get-DistributionGroup -Identity $GroupId -Filter { IsDirSynced -eq $true } -ErrorAction Stop
                    if ($null -eq $ExoGroup) {
                        Write-PSFMessage -Level Warning -Message ('Unable to find synchronized distribution group {0} in Exchange Online. Will not continue with current group.' -f $GroupId)
                        continue
                    }
                    elseif ($ExoGroup.Count -gt 1) {
                        Write-PSFMessage -Level Warning -Message ('More than one distribution group found in Exchange Online with identity {0}. Will not continue with current group.' -f $GroupId)
                        continue
                    }
                    $DistributionGroupObject.EXO = $ExoGroup

                    $ExchGroup = Get-ExchDistributionGroup -Identity $ExoGroup.PrimarySmtpAddress -ErrorAction Stop
                    if ($null -eq $ExchGroup) {
                        Write-PSFMessage -Level Warning -Message ('Unable to find distribution group {0} in Exchange On-premises. Will not continue with current group.' -f $GroupId) -WarningAction Continue
                        continue
                    }
                    elseif ($ExchGroup.Count -gt 1) {
                        Write-PSFMessage -Level Warning -Message ('More than one distribution group found in Exchange On-premises with identity {0}. Will not continue with current group.' -f $GroupId) -WarningAction Continue
                        continue
                    }
                    $DistributionGroupObject.EXCH = $ExchGroup

                    [bool]$NewManager = $false
                    if ($PSBoundParameters.ContainsKey('Manager') -and $ExchGroup.Managedby.Count -gt 0) {
                        [bool]$NewManager = $true
                        Write-PSFMessage -Level Warning -Message ('Will overwrite existing manager "{0}" for group "{1}". Will add "{2}" user as manager.' -f $ExchGroup.Managedby, $GroupId, ($Manager -join ', ')) -WarningAction Continue
                    }
                    elseif ($PSBoundParameters.ContainsKey('Manager') -and $ExchGroup.Managedby.Count -eq 0) {
                        [bool]$NewManager = $true
                        Write-PSFMessage -Level Verbose -Message ('No existing manager found for group {0}. Will add "{1}" user as manager.' -f $GroupId, ($Manager -join ', '))
                    }
                    elseif ($PSBoundParameters.ContainsKey('Force') -and $ExchGroup.Managedby.Count -eq 0) {
                        Write-PSFMessage -Level Warning -Message ('No existing manager found for group {0}. Will add current user as manager.' -f $GroupId) -WarningAction Continue
                    }
                    elseif ($ExchGroup.Managedby.Count -eq 0) {
                        Write-PSFMessage -Level Warning -Message ('No existing manager found. Will not continue with current group {0}.' -f $GroupId) -WarningAction Continue
                        continue Group
                    }
                    if ($NewManager) {
                        foreach ($ManagedBy in $Manager) {
                            $OnlineManagerId = Get-Recipient -Identity $ManagedBy.ToString() -ErrorAction SilentlyContinue
                            if ($OnlineManagerId.RecipientTypeDetails -in $ValidRecipientTypeDetails) {
                                $null = $ValidManagers.Add($OnlineManagerId.PrimarySmtpAddress)
                            }
                        }
                        if (($PSBoundParameters.ContainsKey('Force')) -and $ValidManagers.Count -eq 0) {
                            Write-PSFMessage -Level Warning -Message ('Excluding manager(s) "{0}" for group "{1}" because recipient(s) does not exist in Exchange Online as valid recipient(s).' -f ($Manager -join ', '), $GroupId) -WarningAction Continue
                        }
                        elseif ($ValidManagers.Count -eq 0) {
                            Write-PSFMessage -Level Warning -Message ('Manager(s) "{0}" does not exist in Exchange Online as valid recipient(s). Will not continue with current group "{1}".' -f ($Manager -join ', '), $GroupId) -WarningAction Continue
                            Write-PSFMessage -Level Verbose -Message ('Use the "Force" parameter to manually add your self as Owner for the current group "{0}".' -f $GroupId)
                            continue Group
                        }
                    }
                    else {
                        foreach ($ManagedBy in $ExchGroup.Managedby) {
                            $ManagerId = (Get-EXCHRecipient -Identity $ManagedBy -ErrorAction SilentlyContinue).PrimarySmtpAddress
                            $OnlineManagerId = Get-Recipient -Identity $ManagerId -ErrorAction SilentlyContinue
                            if ($OnlineManagerId.RecipientTypeDetails -in $ValidRecipientTypeDetails) {
                                $null = $ValidManagers.Add($OnlineManagerId.PrimarySmtpAddress)
                            }
                        }
                        if (($PSBoundParameters.ContainsKey('Force')) -and $ValidManagers.Count -eq 0) {
                            Write-PSFMessage -Level Warning -Message ('Only the following manager(s) "{0}" for group "{1}" will be added because the other owner(s)/recipient(s) does not exist in Exchange Online as valid recipient(s).' -f ($ValidManagers -join ', '), $GroupId) -WarningAction Continue
                        }
                        else {
                            Write-PSFMessage -Level Warning -Message ('Manager {0} does not exist in Exchange Online as a valid recipient. Will not continue with current group {1}.' -f $ManagerId, $GroupId) -WarningAction Continue
                            Write-PSFMessage -Level Verbose -Message ('Use the "Force" or "Manager" parameter to manually add your self or specified Owners for the current group "{0}".' -f $GroupId)
                            continue Group
                        }
                    }
                    $DistributionGroupObject.Manager = $ValidManagers

                    $Members = Get-EXCHDistributionGroupMember -Identity $ExchGroup.Identity -ErrorAction SilentlyContinue
                    if ($Members.Count -eq 0) {
                        Write-PSFMessage -Level Warning -Message ('Excluding all members of {0} because no valid recipient(s) members was found.' -f $ExchGroup.Identity) -WarningAction Continue
                    }
                    else {
                        foreach ($Member in $Members) {
                            $OnlineMemberId = Get-Recipient -Identity $Member.PrimarySmtpAddress -ErrorAction SilentlyContinue
                            if ($OnlineMemberId.RecipientTypeDetails -in $ValidRecipientTypeDetails) {
                                $null = $ValidMembers.Add($OnlineMemberId)
                            }
                            elseif ($PSBoundParameters.ContainsKey('Force')) {
                                Write-PSFMessage -Level Warning -Message ('Excluding member {0} for group {1} because recipient does not exist in Exchange Online as a valid recipient.' -f $Member.PrimarySmtpAddress, $GroupId) -WarningAction Continue
                            }
                            else {
                                Write-PSFMessage -Level Warning -Message ('Member {0} does not exist in Exchange Online as a valid recipient. Will not continue with current group {1}.' -f $Member.PrimarySmtpAddress, $GroupId) -WarningAction Continue
                                continue Group
                            }
                        }
                        $DistributionGroupObject.Members = $ValidMembers
                    }

                    $Command = Get-Command -Name New-DistributionGroup -ErrorAction Stop
                    [hashtable]$InitializeNewGroup = @{ }

                    foreach ($Parameter in ($Command.Parameters.GetEnumerator() | Sort-Object)) {
                        if ($Parameter.Key -match $ExcludeNew) {
                            continue
                        }
                        elseif ($Parameter.Key -match $AddPrefix -and ($DistributionGroupObject.EXCH."$($Parameter.Key)")) {
                            Write-PSFMessage -Level Verbose -Message ('Adding prefix "{0}" for property {1}.' -f $Prefix, $Parameter.Key)
                            if ($Parameter.Key -eq 'PrimarySmtpAddress') {
                                $InitializeNewGroup.Add("$($Parameter.Key)", ('{0}{1}' -f $Prefix, $DistributionGroupObject.EXO."$($Parameter.Key)"))
                            }
                            else {
                                $InitializeNewGroup.Add("$($Parameter.Key)", ('{0}{1}' -f $Prefix, $DistributionGroupObject.EXCH."$($Parameter.Key)"))
                            }
                        }
                        elseif ($DistributionGroupObject.EXCH."$($Parameter.Key)") {
                            $InitializeNewGroup.Add("$($Parameter.Key)", $DistributionGroupObject.EXCH."$($Parameter.Key)")
                        }
                    }

                    $InitializedNewGroup = New-DistributionGroup @InitializeNewGroup -ErrorAction Stop
                    Write-PSFMessage -Level Host -Message ('Successfully created a cloud only distribution group with identity "{0}".' -f $InitializedNewGroup.PrimarySmtpAddress)
                    $DistributionGroupObject.InitializedGroup = $InitializedNewGroup

                    $Command = Get-Command -Name Set-DistributionGroup -ErrorAction Stop
                    [hashtable]$InitializeSetGroup = @{ }

                    foreach ($Parameter in ($Command.Parameters.GetEnumerator() | Sort-Object)) {
                        if ($Parameter.Key -match $ExcludeSet) {
                            continue
                        }
                        elseif ($Parameter.Key -match 'EmailAddresses' -and ($DistributionGroupObject.EXCH."$($Parameter.Key)")) {
                            Write-PSFMessage -Level Verbose -Message ('Adding prefix "{0}" for property {1}.' -f $Prefix, $Parameter.Key)
                            $EmailAddresses = foreach ($Address in $DistributionGroupObject.EXO.EmailAddresses) {
                                $VerifyEmailDomain = $Address -replace '.+:.+\@'
                                if ($Address -match '^smtp\:' -and $AcceptedDomain.DomainName -contains $VerifyEmailDomain) {
                                    $Address -replace '^(smtp\:)(.+)', ('$1{0}$2' -f $Prefix)
                                }
                            }
                            $InitializeSetGroup.Add("$($Parameter.Key)", $EmailAddresses)
                        }
                        elseif ($DistributionGroupObject.EXCH."$($Parameter.Key)") {
                            $InitializeSetGroup.Add("$($Parameter.Key)", $DistributionGroupObject.EXCH."$($Parameter.Key)")
                        }
                    }

                    if ($DistributionGroupObject.Manager) {
                        $InitializeSetGroup.Add('ManagedBy', $DistributionGroupObject.Manager)
                    }

                    Write-PSFMessage -Level Verbose -Message ('Updating properties for distribution group {0}.' -f $InitializedNewGroup.PrimarySmtpAddress)
                    Set-DistributionGroup -Identity $InitializedNewGroup.PrimarySmtpAddress @InitializeSetGroup -HiddenFromAddressListsEnabled:$true -BypassSecurityGroupManagerCheck -ErrorAction Stop
                    Write-PSFMessage -Level Verbose -Message ('Updating membership for distribution group {0}.' -f $InitializedNewGroup.PrimarySmtpAddress)
                    if ($DistributionGroupObject.Members.Count -gt 0) {
                        Update-DistributionGroupMember -Identity $InitializedNewGroup.PrimarySmtpAddress -Members @($DistributionGroupObject.Members.PrimarySmtpAddress) -BypassSecurityGroupManagerCheck -Confirm:$false -ErrorAction Stop
                    }
                    $InitializedGroup = Get-DistributionGroup -Identity $InitializedNewGroup.PrimarySmtpAddress -ErrorAction Stop

                    $DistributionGroupObject.InitializedGroup = $InitializedGroup
                    $DistributionGroupObject | Export-PSFClixml -Path "$LogPath\$GroupId.byte" -Depth 5 -ErrorAction Stop
                    Write-PSFMessage -Level Host -Message ('Exported a PSFClixml object of the distribution group, before and after initialization, to "{0}".' -f "$LogPath\$GroupId.byte")
                    Write-PSFMessage -Level Verbose -Message ('Use Import-PFClixml -Path "{0}" to view the content.' -f "$LogPath\$GroupId.byte")
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