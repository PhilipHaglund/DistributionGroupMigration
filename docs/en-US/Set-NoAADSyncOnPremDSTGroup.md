---
external help file: DistributionGroupMigration-help.xml
Module Name: DistributionGroupMigration
online version: https://github.com/PhilipHaglund/DistributionGroupMigration/blob/master/docs/en-US/Set-NoAADSyncOnPremDSTGroup.md
schema: 2.0.0
---

# Set-NoAADSyncOnPremDSTGroup

## SYNOPSIS
Set the 'adminDescription' property to 'Group_%PARAM%' for one or more distribution groups generated from Initialize-OnPremDSTGroupToCloud.

## SYNTAX

```
Set-NoAADSyncOnPremDSTGroup [-Group] <String[]> [-ExchangeServer] <String> [[-LogPath] <String>] [-Force]
 [[-Suffix] <String>] [-NoMFA] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Set-NoAADSyncOnPremDSTGroup will set the 'adminDescription' property to 'Group_%PARAM%' so the target distribution group is excluded from the Azure AD Connect synchronization.
Set-NoAADSyncOnPremDSTGroup requires that PSFClixml objects exist in the target LogPath location which is generated from Initialize-OnPremDSTGroupToCloud.
The function Set-NoAADSyncOnPremDSTGroup goes through the following steps:

1.
Validate that the distribution group is exist in both Exchange Online and Exchange On-premises and that the property, "IsDirSynced", exist for the Exchange Online distribution group.
2.
Validate that the initialized distribution group is exist in Exchange Online.
3.
Set the 'adminDescription' property to 'Group_%PARAM%' for the target distribution group in Active Directory, which will remove the Exchange Online distribution group after the next AAD Connect sync cycle.

Notice: The ActiveDirectory module is required for this function to work.

## EXAMPLES

### EXAMPLE 1
```
Set-NoAADSyncOnPremDSTGroup -Group 'dstgroup001@contoso.com' -ExchangeServer exchprod01.contoso.com
```

\[11:12:06\]\[Set-NoAADSyncOnPremDSTGroup\] Successfully set the adminDescription property to "Group_NoAADSync" for the source distribution group "dstgroup001@contoso.com".

This example sets the adminDescription property to 'Group_NoAADSync' for the target source distribution group "dstgroup001@contoso.com" using Active Directory.

### EXAMPLE 2
```
Set-NoAADSyncOnPremDSTGroup -Group 'dstgroup002@contoso.com' -ExchangeServer exchprod01.contoso.com -NoMFA
```

\[11:12:06\]\[Set-NoAADSyncOnPremDSTGroup\] Successfully set the adminDescription property to "Group_NoAADSync" for the source distribution group "dstgroup002@contoso.com".

This example sets the adminDescription property to 'Group_NoAADSync' for the target source distribution group "dstgroup001@contoso.com" using Active Directory.
When NoMFA switch is issued the connection to Exchange Online PowerShell will be using the native experience instead of modern authentication.

### EXAMPLE 3
```
Set-NoAADSyncOnPremDSTGroup -Group 'dstgroup003@contoso.com' -ExchangeServer exchprod01.contoso.com -LogPath "C:\Log"
```

\[11:12:06\]\[Set-NoAADSyncOnPremDSTGroup\] Successfully set the adminDescription property to "Group_NoAADSync" for the source distribution group "dstgroup003@contoso.com".

This example sets the adminDescription property to 'Group_NoAADSync' for the target source distribution group "dstgroup001@contoso.com" using Active Directory.
The LogPath parameter specifies an alternate path for all logs and the distribution group XML-objects.

### EXAMPLE 4
```
Set-NoAADSyncOnPremDSTGroup -Group 'dstgroup004@contoso.com' -ExchangeServer exchprod01.contoso.com -Suffix 'NoO365Sync'
```

\[11:12:06\]\[Set-NoAADSyncOnPremDSTGroup\] Successfully set the adminDescription property to "Group_NoO365Sync" for the source distribution group "dstgroup004@contoso.com".

This example sets the adminDescription property to 'Group_NoAADSync' for the target source distribution group "dstgroup001@contoso.com" using Active Directory.
The Suffix parameter specifies an alternate suffix for to put in the adminDescription property.

### EXAMPLE 5
```
Set-NoAADSyncOnPremDSTGroup -Group 'dstgroup005@contoso.com' -ExchangeServer exchprod01.contoso.com -Force
```

WARNING: \[11:12:03\]\[Set-NoAADSyncOnPremDSTGroup\] Excluding validation of existence for the initialized distribution group.
\[11:12:06\]\[Set-NoAADSyncOnPremDSTGroup\] Successfully set the adminDescription property to "Group_NoAADSync" for the source distribution group "dstgroup005@contoso.com".

This example removes the source distribution group from Exchange On-premise, exchprod01.contoso.com, with the identity 'dstgroup004@contoso.com'.
The Force parameter will not connect to Exchange Online and validate the existence for the initialized distribution group.

## PARAMETERS

### -Group
Specifies one or more distribution groups to be migrated.
Recommended to use PrimarySmtpAddress as input to have a unique value.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: PrimarySmtpAddress

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ExchangeServer
Specifies an Exchange On-premise server hosting the PowerShell endpoint.

```yaml
Type: String
Parameter Sets: (All)
Aliases: EXCH

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogPath
Specifies the path for all logs and the distribution group XML-objects.
Default the LogPath uses the 'PSFramework.Logging.FileSystem.LogPath' which defaults to "$env:APPDATA\WindowsPowerShell\PSFramework\Logs" for Windows PowerShell and
"$env:APPDATA\PowerShell\PSFramework\Logs" for PowerShell Core.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: (Get-PSFConfigValue -FullName 'PSFramework.Logging.FileSystem.LogPath')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Specifies that no validation will take place for the existence of the initialized distribution group before the distribution group removal.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Suffix
Specifies the suffix for the property adminDescription.
Default the suffix is 'NoAADSync'.
The string will concatenate the \[string\]'Group_' with $Suffix.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: NoAADSync
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoMFA
Specifies that No MFA will be used when connecting to Exchange Online.
If the Force parameter is specified the NoMFA parameter will have no effect.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/PhilipHaglund/DistributionGroupMigration/blob/master/docs/en-US/Set-NoAADSyncOnPremDSTGroup.md](https://github.com/PhilipHaglund/DistributionGroupMigration/blob/master/docs/en-US/Set-NoAADSyncOnPremDSTGroup.md)

