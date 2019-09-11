---
external help file: DistributionGroupMigration-help.xml
Module Name: DistributionGroupMigration
online version: https://github.com/PhilipHaglund/DistributionGroupMigration/blob/master/docs/en-US/Remove-OnPremDSTGroup.md
schema: 2.0.0
---

# Remove-OnPremDSTGroup

## SYNOPSIS
Remove one or more distribution groups in Exchange On-premise generated from Initialize-OnPremDSTGroupToCloud.

## SYNTAX

```
Remove-OnPremDSTGroup [-Group] <String[]> [-ExchangeServer] <String> [[-LogPath] <String>] [-Force] [-NoMFA]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Remove-OnPremDSTGroup will remove the original distribution group in Exchange On-premise (also Active Directory) with data from Initialize-OnPremDSTGroupToCloud.
Remove-OnPremDSTGroup requires that PSFClixml objects exist in the target LogPath location which is generated from Initialize-OnPremDSTGroupToCloud.
The function Remove-OnPremDSTGroup goes through the following steps:

1.
Validate that the distribution group is exist in both Exchange Online and Exchange On-premises and that the property, "IsDirSynced", exist for the Exchange Online distribution group.
2.
Validate that the initialized distribution group is exist in Exchange Online.
3.
Remove the source distribution group from Exchange On-premise, which will also remove the Active Directory object.

## EXAMPLES

### EXAMPLE 1
```
Remove-OnPremDSTGroup -Group 'dstgroup001@contoso.com' -ExchangeServer exchprod01.contoso.com
```

\[11:12:06\]\[Remove-OnPremDSTGroup\] Successfully removed the source distribution group with identity "dstgroup001@contoso.com" from Exchange On-premise.

This example removes the source distribution group from Exchange On-premise, exchprod01.contoso.com, with the identity 'dstgroup001@contoso.com'.

### EXAMPLE 2
```
Remove-OnPremDSTGroup -Group 'dstgroup002@contoso.com' -ExchangeServer exchprod01.contoso.com -NoMFA
```

\[11:12:06\]\[Remove-OnPremDSTGroup\] Successfully removed the source distribution group with identity "dstgroup002@contoso.com" from Exchange On-premise.

This example removes the source distribution group from Exchange On-premise, exchprod01.contoso.com, with the identity 'dstgroup002@contoso.com'.
When NoMFA switch is issued the connection to Exchange Online PowerShell will be using the native experience instead of modern authentication.

### EXAMPLE 3
```
Remove-OnPremDSTGroup -Group 'dstgroup003@contoso.com' -ExchangeServer exchprod01.contoso.com -LogPath "C:\Log"
```

\[11:12:06\]\[Remove-OnPremDSTGroup\] Successfully removed the source distribution group with identity "dstgroup003@contoso.com" from Exchange On-premise.

This example removes the source distribution group from Exchange On-premise, exchprod01.contoso.com, with the identity 'dstgroup003@contoso.com'.
The LogPath parameter specifies an alternate path for all logs and the distribution group XML-objects.

### EXAMPLE 4
```
Remove-OnPremDSTGroup -Group 'dstgroup004@contoso.com' -ExchangeServer exchprod01.contoso.com -Force
```

WARNING: \[11:12:03\]\[Remove-OnPremDSTGroup\] Excluding validation of existence for the initialized distribution group.
\[11:12:06\]\[Remove-OnPremDSTGroup\] Successfully removed the source distribution group with identity "dstgroup004@contoso.com" from Exchange On-premise.

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

[https://github.com/PhilipHaglund/DistributionGroupMigration/blob/master/docs/en-US/Remove-OnPremDSTGroup.md](https://github.com/PhilipHaglund/DistributionGroupMigration/blob/master/docs/en-US/Remove-OnPremDSTGroup.md)

