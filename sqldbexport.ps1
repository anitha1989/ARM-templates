#Creating SQL Server and SQL DB
$User = "anitha"
$PWord = ConvertTo-SecureString -String "ishanth@2014" -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord

#SQL SERVER

New-AzSqlServer -ResourceGroupName ps-rg -Location 'east us' -ServerName sqlserver8765 -SqlAdministratorCredentials $Credential -Verbose


#SQL DB

New-AzSqlDatabase -ResourceGroupName ps-rg -Name sqldb8765 -Edition Basic -BackupStorageRedundancy Geo -ServerName sqlserver8765 -Verbose

#Creating Storage Account

$stgacc = New-AzStorageAccount -ResourceGroupNam ps-rg -Location 'east us' -Name stgaccdemo8765 -SkuName Standard_LRS -Kind StorageV2 -AccessTier Hot -Verbose

#Create container in Storage Account

$stg = $stgacc.Context

New-AzStorageContainer -Name container1 -Context $stg -Permission Blob

-----------------------
#SQL Export
$User = "anitha"
$PWord = ConvertTo-SecureString -String "ishanth@2014" -AsPlainText -Force

# The ip address range that you want to allow to access your server
$startip = "0.0.0.0"
$endip = "0.0.0.0"
New-AzSqlServerFirewallRule -ServerName sqlserver8765 -FirewallRuleName rule1 -ResourceGroupName ps-rg -StartIpAddress 0.0.0.0 -EndIpAddress 0.0.0.0 -Verbose

New-AzSqlDatabaseExport -DatabaseName sqldb8765 -ServerName sqlserver8765 -StorageKeyType StorageAccessKey -StorageKey '9iEYImhISapDy2tSdrKTTgEmT5BBv2KUKcDx+Rkk2znn0lMwPdNPhsYWLwL3CeM2SA7mM73lrplPm2472epi0Q==' -StorageUri 'https://stgaccdemo8765.blob.core.windows.net/export/sqldb8765-2021-10-27-15-39.bacpac' -AdministratorLogin $User -AdministratorLoginPassword $PWord -ResourceGroupName ps-rg -verbose



#SQL Import
New-AzSqlDatabaseImport -DatabaseName sqldb8765456 -ServerName sqlserver8765 -Edition Basic -DatabaseMaxSizeBytes 2GB -StorageKeyType StorageAccessKey -StorageKey 'YgiesXiYoP2/CDubhAp+aOjHrFZBqHlBhG5EzBB2OZr0+Y2MdSPosJpafxUcmD9IU/psHN37yKLgTp7WOTUvLA==' -StorageUri 'https://stgaccdemo8765.blob.core.windows.net/export/sqldb8765-2021-10-27-15-39.bacpac' -ServiceObjectiveName Basic -AdministratorLogin $User -AdministratorLoginPassword $PWord -AuthenticationType None -ResourceGroupName ps-rg -Verbose 

#To know the status of the export import database
 $importRequest = New-AzSqlDatabaseImport -DatabaseName sqldb8765456 -ServerName sqlserver8765 -Edition Basic -DatabaseMaxSizeBytes 2GB -StorageKeyType StorageAccessKey -StorageKey 'P+WQVcAsZJfmfENWi4HFmfTtOvWKPBsKFrbUhY7EtDB6Vq1eSKa5qJ3XbYeeMRkwE4Vt9sKgv9Ey4y7LmUWqsA==' -StorageUri 'https://stgacc8765.blob.core.windows.net/container1/sqldb8765-2021-10-27-22-04.bacpac' -ServiceObjectiveName Basic -AdministratorLogin $User -AdministratorLoginPassword $PWord -AuthenticationType None -ResourceGroupName ps-rg -Verbose
 
  [Console]::Write("Importing")
>> while ($importStatus.Status -eq "InProgress")
>> {
>>     $importStatus = Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink
>>     [Console]::Write(".")
>> }
>> [Console]::WriteLine("")
>> $importStatus