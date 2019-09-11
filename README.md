# DistributionGroupMigration
Migrate Exchange On-premise distribution groups to Exchange Online (Office 365).
![DistributionGroupMigration](https://raw.githubusercontent.com/PhilipHaglund/DistributionGroupMigration/master/DistributionGroupMigration.png "DistributionGroupMigration")

| Azure Pipelines (master) | PS Gallery | License
|---|---|---|
[![Build Status](https://dev.azure.com/omnicit/DistributionGroupMigration/_apis/build/status/PhilipHaglund.DistributionGroupMigration?branchName=master)](https://dev.azure.com/omnicit/DistributionGroupMigration/_apis/build/status/PhilipHaglund.DistributionGroupMigration?branchName=master) | [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/DistributionGroupMigration.svg)](https://www.powershellgallery.com/packages/DistributionGroupMigration/) | [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Have you seen the following message:
```PowerShell
The action 'Set-DistributionGroup', '<property>', can't be performed on the object '<name>' because the object is being synchronized from your on-premises organization. This action should be performed on the object in your on-premises organization.
```

This is because owners of an on-premises distribution group that's synced to Office 365 can't manage the distribution group in Exchange Online.
The module DistributionGroupMigration is designed to help with this by migrating Exchange On-premise distribution groups to Exchange Online (Office 365).

## Requirements
- Exchange Hybrid deployment

## Installation

If you have the [PowerShellGet](https://docs.microsoft.com/en-us/powershell/gallery/overview) module installed
you can enter the following command:

Install to your personal PowerShell modules folder:
```PowerShell
Install-Module -Name DistributionGroupMigration -Scope CurrentUser
Import-Module -Name DistributionGroupMigration
```

Install for everyone:
```PowerShell
Install-Module -Name DistributionGroupMigration
Import-Module -Name DistributionGroupMigration
```

## Documentation

You can learn how to use the functions by reading the documentation:

- [Cmdlet Overview](docs/en-US/DistributionGroupMigration.md)

## Usage
***Recommended to verify in a non-production environment. If that isn't possible, use a non-production distribution group.***

The functions ```Complete-OnPremDSTGroupToCloud```, ```Remove-OnPremDSTGroup``` and ```Set-NoAADSyncOnPremDSTGroup``` will fail if the Initialize-OnPremDSTGroupToCloud haven't been initiated. This is because the ```Initialize-OnPremDSTGroupToCloud``` creates PSFClixml files which is used on those three functions.

This is a basic overview on how to migrate a distribution group.
1. View the examples.
```PowerShell
Get-Help -Name Initialize-OnPremDSTGroupToCloud -Examples
Get-Help -Name Complete-OnPremDSTGroupToCloud -Examples
Get-Help -Name Remove-OnPremDSTGroup -Examples
Get-Help -Name Set-NoAADSyncOnPremDSTGroup -Examples
```
2. Run ```Initialize-OnPremDSTGroupToCloud``` with the parameters of your choice.
3. Choose whether  to run the ```Remove-OnPremDSTGroup``` or ```Set-NoAADSyncOnPremDSTGroup``` function depending on your needs.
4. Initialize a AAD Connect synchronization using [Start-ADSyncSyncCycle](https://docs.microsoft.com/en-us/azure/active-directory/hybrid/how-to-connect-sync-feature-scheduler#start-the-scheduler) or wait for the [automatic synchronization](https://docs.microsoft.com/en-us/azure/active-directory/hybrid/how-to-connect-sync-feature-scheduler) to take place.
5. Run ```Complete-OnPremDSTGroupToCloud``` to complete the migration.
6. Verify that the distribution group has the correct properties and working, i.e. send a mail message to the distribution group.

If you put it all together:
```PowerShell
Initialize-OnPremDSTGroupToCloud -Group 'dstgroup001@contoso.com' -ExchangeServer exchprod01.contoso.com
Set-NoAADSyncOnPremDSTGroup -Group 'dstgroup001@contoso.com' -ExchangeServer exchprod01.contoso.com
# Remove-OnPremDSTGroup -Group 'dstgroup001@contoso.com' -ExchangeServer exchprod01.contoso.com
Invoke-Command -ComputerName "<AADConnectServerName>" -ScriptBlock {Start-ADSyncSyncCycle}
Complete-OnPremDSTGroupToCloud -Group 'dstgroup001@contoso.com'
# Optional, remove the group after completion. Force must be used when Complete-OnPremDSTGroupToCloud was ran before Remove-OnPremDSTGroup.
Remove-OnPremDSTGroup -Group 'dstgroup001@contoso.com' -ExchangeServer exchprod01.contoso.com -Force
```
### Rollback
If for some reason a rollback is needed all distribution group objects is saved in [PSFClixml](http://psframework.org/documentation/commands/PSFramework/Import-PSFClixml.html).

1. The ```LogPath``` location provided in ```Initialize-OnPremDSTGroupToCloud``` contains all PSFClixml as well as all logs.
2. Retrieve a distribution group that will be used in the rollback.
```PowerShell
$DistributionGroupObject = Import-PSFClixml -Path "<Path>"
```
3. Remove the Exchange Online distribution group created from ```Initialize-OnPremDSTGroupToCloud``` and renamed with ```Complete-OnPremDSTGroupToCloud```.
```PowerShell
Remove-DistributionGroup -Identity $DistributionGroupObject.CompletedGroup.PrimarySmtpAddress -Confirm
```
4. Depending on if the Exchange On-premise distribution group was removed using ```Remove-OnPremDSTGroup``` or just set not to synchronize ```Set-NoAADSyncOnPremDSTGroup```, reverse that step.

    - Recreate the distribution group:
    ```PowerShell
    $Recreate = $DistributionGroupObject.EXCH
    New-EXCHDistributionGroup @Recreate
    ```
    - Remove NoSync attribute:
    ```PowerShell
    Set-ADGroup -Identity $DistributionGroupObject.EXCH.DistinguishedName -Clear 'adminDescription'
    ```
5. Initialize a AAD Connect synchronization using [Start-ADSyncSyncCycle](https://docs.microsoft.com/en-us/azure/active-directory/hybrid/how-to-connect-sync-feature-scheduler#start-the-scheduler) or wait for the [automatic synchronization](https://docs.microsoft.com/en-us/azure/active-directory/hybrid/how-to-connect-sync-feature-scheduler) to take place.

## Maintainers

- [Philip Haglund](https://github.com/PhilipHaglund) - [@KPHaglund](http://twitter.com/KPHaglund)

## License

This project is licensed under the [MIT](LICENSE).
