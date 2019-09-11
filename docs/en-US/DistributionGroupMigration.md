---
Module Name: DistributionGroupMigration
Module Guid: c49cee3a-2c8e-4fc2-a6dd-944d437e042e
Download Help Link: https://github.com/PhilipHaglund/DistributionGroupMigration/tree/master/docs/en-US
Help Version: 0.1.0
Locale: en-US
---

# DistributionGroupMigration Module
## Description
Migrate Exchange On-premise distribution groups to Exchange Online (Office 365).

## DistributionGroupMigration Cmdlets
### [Initialize-OnPremDSTGroupToCloud](Initialize-OnPremDSTGroupToCloud.md)
Creates a copy of one or more synchronized (Azure AD Connect) distribution groups in Exchange Online with a defined prefix.

### [Set-NoAADSyncOnPremDSTGroup](Set-NoAADSyncOnPremDSTGroup.md)
Set the 'adminDescription' property to 'Group_%PARAM%' for one or more distribution groups generated from Initialize-OnPremDSTGroupToCloud.

### [Remove-OnPremDSTGroup](Remove-OnPremDSTGroup.md)
Remove one or more distribution groups in Exchange On-premise generated from Initialize-OnPremDSTGroupToCloud.

### [Complete-OnPremDSTGroupToCloud](Complete-OnPremDSTGroupToCloud.md)
Completes a migration of one or more synchronized (Azure AD Connect) distribution groups in Exchange Online generated from Initialize-OnPremDSTGroupToCloud.