---
external help file: DistributionGroupMigration-help.xml
Module Name: DistributionGroupMigration
online version: https://github.com/PhilipHaglund/DistributionGroupMigration/blob/master/docs/en-US/Initialize-OnPremDSTGroupToCloud.md
schema: 2.0.0
---

# Initialize-OnPremDSTGroupToCloud

## SYNOPSIS
Creates a copy of one or more synchronized (Azure AD Connect) distribution groups in Exchange Online with a defined prefix.

## SYNTAX

```
Initialize-OnPremDSTGroupToCloud [-Group] <String[]> [-ExchangeServer] <String> [[-Prefix] <String>] [-Force]
 [[-LogPath] <String>] [-NoMFA] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Initialize-OnPremDSTGroupToCloud will create a copy of one or more synchronized (Azure AD Connect) distribution groups in Exchange Online with a defined prefix, default 'PreMig-.
The function Initialize-OnPremDSTGroupToCloud goes through the following steps:

1.
Validate that the distribution group is exist in both Exchange Online and Exchange On-premises and that the property, "IsDirSynced", exist for the Exchange Online distribution group.
2.
Validate Members of the distribution group.
If the Members object is not existing in Exchange Online as a valid mail recipient the function will hard fail unless the force parameter is used.
3.
Validate ManagedBy of the distribution group.
If the ManagedBy object is not an existing in Exchange Online as a valid mail recipient the function will hard fail unless the force parameter is used.
4.
Creates a copy of the synchronized distribution group in Exchange Online with a defined prefix on all properties that must remain unique.

The following properties will receive the prefix for the created distribution group:
"Alias", "DisplayName", "Name", "PrimarySmtpAddress", "EmailAddresses"

## EXAMPLES

### EXAMPLE 1
```
Initialize-OnPremDSTGroupToCloud -Group 'dstgroup001@contoso.com' -ExchangeServer exchprod01.contoso.com
```

\[11:12:06\]\[Initialize-OnPremDSTGroupToCloud\] Successfully created a cloud only distribution group with identity "PreMig-dstgroup001@contoso.com".
\[11:12:06\]\[Initialize-OnPremDSTGroupToCloud\] Exported a PSFClixml object of the distribution group, before and after initialization, to "C:\Users\UserName\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\dstgroup001@contoso.com.byte".

This example creates a "Cloud Only" (Exchange Online) copy of the Exchange On-premise distribution group 'dstgroup001@contoso.com' with the prefix 'PreMig-'.

### EXAMPLE 2
```
Initialize-OnPremDSTGroupToCloud -Group 'dstgroup002@contoso.com' -ExchangeServer exchprod01.contoso.com -Prefix 'Mig1234-'
```

\[11:12:06\]\[Initialize-OnPremDSTGroupToCloud\] Successfully created a cloud only distribution group with identity "Mig1234-dstgroup002@contoso.com".
\[11:12:06\]\[Initialize-OnPremDSTGroupToCloud\] Exported a PSFClixml object of the distribution group, before and after initialization, to "C:\Users\UserName\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\dstgroup002@contoso.com.byte".

This example creates a "Cloud Only" (Exchange Online) copy of the Exchange On-premise distribution group 'dstgroup001@contoso.com' with the prefix 'Mig1234-'.

### EXAMPLE 3
```
Initialize-OnPremDSTGroupToCloud -Group 'dstgroup003@contoso.com' -ExchangeServer exchprod01.contoso.com -Force
```

WARNING: \[11:12:03\]\[Initialize-OnPremDSTGroupToCloud\] Excluding manager Administrator@contoso.local for group dstgroup003@contoso.com because recipient does not exist in Exchange Online as a valid recipient.
WARNING: \[11:12:03\]\[Initialize-OnPremDSTGroupToCloud\] Excluding member  Administrator@contoso.local for group dstgroup003@contoso.com because recipient does not exist in Exchange Online as a valid recipient.

\[11:12:06\]\[Initialize-OnPremDSTGroupToCloud\] Successfully created a cloud only distribution group with identity "PreMig-dstgroup003@contoso.com".
\[11:12:06\]\[Initialize-OnPremDSTGroupToCloud\] Exported a PSFClixml object of the distribution group, before and after initialization, to "C:\Users\UserName\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\dstgroup003@contoso.com.byte".

This example creates a "Cloud Only" (Exchange Online) copy of the Exchange On-premise distribution group 'dstgroup001@contoso.com' with the prefix 'PreMig-'.
If any member of the Members property or and manager of the ManagedBy property does not exist as a valid mail recipient in Exchange Online,
that member or manager will be excluded from the created distribution group in Exchange Online.

### EXAMPLE 4
```
Initialize-OnPremDSTGroupToCloud -Group 'dstgroup004@contoso.com' -ExchangeServer exchprod01.contoso.com -NoMFA
```

\[11:12:06\]\[Initialize-OnPremDSTGroupToCloud\] Successfully created a cloud only distribution group with identity "PreMig-dstgroup004@contoso.com".
\[11:12:06\]\[Initialize-OnPremDSTGroupToCloud\] Exported a PSFClixml object of the distribution group, before and after initialization, to "C:\Users\UserName\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\dstgroup004@contoso.com.byte".

This example creates a "Cloud Only" (Exchange Online) copy of the Exchange On-premise distribution group 'dstgroup001@contoso.com' with the prefix 'Mig1234-'.
When NoMFA switch is issued the connection to Exchange Online PowerShell will be using the native experience instead of modern authentication.

### EXAMPLE 5
```
Initialize-OnPremDSTGroupToCloud -Group 'dstgroup005@contoso.com' -ExchangeServer exchprod01.contoso.com -LogPath "C:\Log"
```

\[11:12:06\]\[Initialize-OnPremDSTGroupToCloud\] Successfully created a cloud only distribution group with identity "PreMig-dstgroup005@contoso.com".
\[11:12:06\]\[Initialize-OnPremDSTGroupToCloud\] Exported a PSFClixml object of the distribution group, before and after initialization, to "C:\Log\dstgroup005@contoso.com.byte".

This example creates a "Cloud Only" (Exchange Online) copy of the Exchange On-premise distribution group 'dstgroup005@contoso.com' with the prefix 'PreMig-'.
The LogPath parameter specifies an alternate path for all logs and the distribution group XML-objects.

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

### -Prefix
Specifies a prefix to be used when creating a duplicate distribution group.
Default value 'PreMig-'
To avoid already existing prefixes use a prefix which is unique.
Validation will occur against the regular expression "^\[a-z0-9\]{4,9}\-".
"a-z" a single character in the range between a and z (case insensitive)
"0-9" a single character in the range between 0 and 9 (case insensitive)
"{4,9}" Matches between 4 and 9 times, as many times as possible
"\-"" matches the character - literally (case insensitive)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: PreMig-
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Specifies that managers and members of a distribution group will be removed from the distribution group if they don't are eligible to be a manager or member of a cloud only distribution group.

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

### -LogPath
Specifies the path for all logs and the distribution group XML-objects.
Default the LogPath uses the 'PSFramework.Logging.FileSystem.LogPath' which defaults to "$env:APPDATA\WindowsPowerShell\PSFramework\Logs" for Windows PowerShell and
"$env:APPDATA\PowerShell\PSFramework\Logs" for PowerShell Core.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: (Get-PSFConfigValue -FullName 'PSFramework.Logging.FileSystem.LogPath')
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoMFA
Specifies that No MFA will be used when connecting to Exchange Online.

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

[https://github.com/PhilipHaglund/DistributionGroupMigration/blob/master/docs/en-US/Initialize-OnPremDSTGroupToCloud.md](https://github.com/PhilipHaglund/DistributionGroupMigration/blob/master/docs/en-US/Initialize-OnPremDSTGroupToCloud.md)

