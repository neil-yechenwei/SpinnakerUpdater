#!/bin/bash

PATH=$PATH:~/.nvm/versions/node/v10.15.1/bin:~/bin:~/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
export PATH

CURRENT_DATE=`date '+%Y_%m_%d'`
CURRENT_DATE_TIME=`date '+%Y_%m_%d_%H_%M_%S'`
DAILY_LOGS=~/spinnaker_updater_logs/${CURRENT_DATE}
Message=""

# Check the status of last command
function CheckLastCommandStatus() {
  if [ $? -ne 0 ]
  then
    JOB_STATUS="Failure"
  else
    JOB_STATUS="Success"
  fi
  
  Message_Title=$1
  Message_Body=$(<$2)
  Message+="[$JOB_STATUS][${Message_Title}]:\n${Message_Body}\n\n"
}

mkdir -p ${DAILY_LOGS}

hal deploy apply >> ${DAILY_LOGS}/apply_${CURRENT_DATE_TIME}.log 2>&1

CheckLastCommandStatus "Deploy spinnaker" ${DAILY_LOGS}/apply_${CURRENT_DATE_TIME}.log

hal deploy connect >> ${DAILY_LOGS}/connect_${CURRENT_DATE_TIME}.log 2>&1

CheckLastCommandStatus "Connect to the spinnaker ui" ${DAILY_LOGS}/connect_${CURRENT_DATE_TIME}.log

echo -e "${Message}" | mail -s "The status of spinnaker daily update" v-cheye@microsoft.com
