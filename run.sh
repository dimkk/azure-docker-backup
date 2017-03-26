#!/bin/bash

AZ_USER=${AZ_USER}
AZ_SECRET=${AZ_SECRET}
AZ_AD_TENANT_ID=${AZ_AD_TENANT_ID}
AZ_STORAGE_FOLDER=${AZ_STORAGE_FOLDER}
AZ_STORAGE_SHARE=${AZ_STORAGE_SHARE}
AZ_STORAGE_CS=${AZ_STORAGE_CS}

[ -z "${AZ_USER}" ] && { echo "=> AZ_USER cannot be empty" && exit 1; }
[ -z "${AZ_SECRET}" ] && { echo "=> AZ_SECRET cannot be empty" && exit 1; }
[ -z "${AZ_AD_TENANT_ID}" ] && { echo "=> AZ_AD_TENANT_ID cannot be empty" && exit 1; }
[ -z "${AZ_STORAGE_SHARE}" ] && { echo "=> AZ_STORAGE_SHARE cannot be empty" && exit 1; }
[ -z "${AZ_STORAGE_CS}" ] && { echo "=> AZ_STORAGE_CS cannot be empty" && exit 1; }

echo "=> Creating backup script"
rm -f /backup.sh
cat <<EOF >> /backup.sh
#!/bin/bash

if [ -n ${AZ_USER} ]; then
    az login --service-principal -u \${AZ_USER} -p "\${AZ_SECRET}" --tenant \${AZ_AD_TENANT_ID}
    az storage directory create -n \${AZ_STORAGE_FOLDER} --share-name \${AZ_STORAGE_SHARE} --connection-string "\${AZ_STORAGE_CS}"
fi

MAX_BACKUPS=${MAX_BACKUPS}

BACKUP_NAME=\$(date +\%Y.\%m.\%d.\%H\%M\%S).*

echo "=> Backup started: \${BACKUP_NAME}"
if [ -n ${AZ_USER} ]; then
    az storage file upload -s ${AZ_STORAGE_SHARE}/${AZ_STORAGE_FOLDER} --source /backup/\${BACKUP_NAME} --connection-string "\${AZ_STORAGE_CS}"
fi

if [ -n "\${MAX_BACKUPS}" ]; then
    while [ \$(ls /backup -N1 | wc -l) -gt \${MAX_BACKUPS} ];
    do
        BACKUP_TO_BE_DELETED=\$(ls /backup -N1 | sort | head -n 1)
        echo "   Backup \${BACKUP_TO_BE_DELETED} is deleted"
        rm -rf /backup/\${BACKUP_TO_BE_DELETED}
        if [ -n ${AZ_USER} ]; then
            az storage file delete -s \${AZ_STORAGE_SHARE} -p \${AZ_STORAGE_FOLDER}/\${BACKUP_TO_BE_DELETED} --connection-string "\${AZ_STORAGE_CS}"
        fi
    done
fi
echo "=> Backup done"
EOF
chmod +x /backup.sh

if [ -n "${INIT_BACKUP}" ]; then
    echo "=> Create a backup on the startup"
    /backup.sh
fi

echo "${CRON_TIME} /backup.sh" > /crontab.conf
crontab  /crontab.conf
echo "=> Running cron job"
exec crond -f