---
external help file: DistributionGroupMigration-help.xml
Module Name: DistributionGroupMigration
online version: https://github.com/PhilipHaglund/DistributionGroupMigration/blob/master/docs/en-US/Complete-OnPremDSTGroupToCloud.md
schema: 2.0.0
---

# Complete-OnPremDSTGroupToCloud

## SYNOPSIS
Completes a migration of one or more synchronized (Azure AD Connect) distribution groups in Exchange Online generated from Initialize-OnPremDSTGroupToCloud.

## SYNTAX

```
Complete-OnPremDSTGroupToCloud [-Group] <String[]> [[-LogPath] <String>] [-NoMFA] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Complete-OnPremDSTGroupToCloud will rename and remove the prefix from the distribution group created from Initialize-OnPremDSTGroupToCloud.
Complete-OnPremDSTGroupToCloud requires that PSFClixml objects exist in the target LogPath location which is generated from Initialize-OnPremDSTGroupToCloud.
The function Complete-OnPremDSTGroupToCloud goes through the following steps:

1.
Validate that the initialized distribution group is exist in Exchange Online.
2.
Validate that the old synchronized distribution does not exist in Exchange Online.
3.
Remove the prefix from all properties on the initialized distribution group in Exchange Online.

The following properties will have the prefix removed for the initialized distribution group:
"Alias", "DisplayName", "Name", "PrimarySmtpAddress", "EmailAddresses"

## EXAMPLES

### EXAMPLE 1
```
Complete-OnPremDSTGroupToCloud -Group 'dstgroup001@contoso.com'
```

\[11:12:06\]\[Complete-OnPremDSTGroupToCloud\] Successfully removed the prefix from all properties on "dstgroup001@contoso.com".
\[11:12:06\]\[Complete-OnPremDSTGroupToCloud\] Exported a PSFClixml object of the distribution group, before and after completion, to "C:\Users\UserName\AppData\Roaming\WindowsPowerShell\PSFramework\Logs".

This example retrieves the exported initialized distribution group object from the default path and removes the prefix.

### EXAMPLE 2
```
Complete-OnPremDSTGroupToCloud -Group 'dstgroup002@contoso.com' -LogPath "C:\Log"
```

\[11:12:06\]\[Complete-OnPremDSTGroupToCloud\] Successfully removed the prefix from all properties on "dstgroup002@contoso.com".
\[11:12:06\]\[Complete-OnPremDSTGroupToCloud\] Exported a PSFClixml object of the distribution group, before and after completion, to "C:\Log".

This example retrieves the exported initialized distribution group object from the defined path "C:\Log" and removes the prefix.
The LogPath parameter specifies an alternate path for where all logs and the distribution group XML-objects is created from Initialize-OnPremDSTGroupToCloud.

### EXAMPLE 3
```
Complete-OnPremDSTGroupToCloud -Group 'dstgroup003@contoso.com' -NoMFA
```

\[11:12:06\]\[Complete-OnPremDSTGroupToCloud\] Successfully removed the prefix from all properties on "dstgroup003@contoso.com".
\[11:12:06\]\[Complete-OnPremDSTGroupToCloud\] Exported a PSFClixml object of the distribution group, before and after completion, to "C:\Users\UserName\AppData\Roaming\WindowsPowerShell\PSFramework\Logs".

This example retrieves the exported initialized distribution group object from the default path and removes the prefix.
When NoMFA switch is issued the connection to Exchange Online PowerShell will be using the native experience instead of modern authentication.

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

### -LogPath
Specifies the path for all logs and the distribution group XML-objects.
Default the LogPath uses the 'PSFramework.Logging.FileSystem.LogPath' which defaults to "$env:APPDATA\WindowsPowerShell\PSFramework\Logs" for Windows PowerShell and
"$env:APPDATA\PowerShell\PSFramework\Logs" for PowerShell Core.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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

[https://github.com/PhilipHaglund/DistributionGroupMigration/blob/master/docs/en-US/Complete-OnPremDSTGroupToCloud.md](https://github.com/PhilipHaglund/DistributionGroupMigration/blob/master/docs/en-US/Complete-OnPremDSTGroupToCloud.md)

