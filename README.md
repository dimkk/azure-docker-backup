# mysql-backup azure

This image runs mysqldump to backup data using cronjob to folder `/backup` and azure storage service

## Usage:

    docker run -d \
        --volume-from mysql_backup
        --env AZ_USER=[Application ID GUID] \
        --env AZ_SECRET=[Application KEY] \
        --env AZ_AD_TENANT_ID=[Tenant AD ID GUID] \
        --env AZ_STORAGE_SHARE=[Share name] \
        --env AZ_STORAGE_FOLDER=[Folder to save] \
        --env AZ_STORAGE_CS=[Storage connection string] \
        dimkk/azure-docker-backup

## Parameters

    CRON_TIME       the interval of cron job to run mysqldump. `0 0 * * *` by default, which is every day at 00:00
    MAX_BACKUPS     the number of backups to keep. When reaching the limit, the old backup will be discarded. No limit by default
    INIT_BACKUP     if set, create a backup when the container starts
    AZ_USER         azure application guid, to get it, and AZ_SECRET, if set, azure save/delete will work [read here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal)
    AZ_SECRET       azure application secret
    AZ_AD_TENANT_ID azure Active Directory Tenant ID, you can find it here -> https://manage.windowsazure.com/serco.onmicrosoft.com#Workspaces/ActiveDirectoryExtension/Directory/**<Tenant ID GUID>**/directoryQuickStart
    AZ_STORAGE_FOLDER azure folder in share to save backups
    AZ_STORAGE_SHARE azure share name - create it yourself!
    AZ_STORAGE_CS   azure storage connection string

## Volume
    There must be volumes from sql or mongo backup containers