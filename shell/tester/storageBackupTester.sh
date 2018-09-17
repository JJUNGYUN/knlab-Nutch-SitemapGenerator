#!/bin/bash

help()
{
	echo "Usage : $0 -crawlId [crawlId]"
}

crawlId=$2

if [ -z ${crawlId} ]
	then
		help
		exit 0
	fi

PEPPER_HOME="/pepper/haena-pepper-1.0.0"

echo "PEPPER_HOME : ${PEPPER_HOME}"

########## STORAGE BACKUP JOB START ##########

echo ""
echo "########## URL INFO UPDATE JOB ##########"
echo "java -cp ${PEPPER_HOME}/ext process.URLInfoUpdater -crawlId ${crawlId}"
java -cp ${PEPPER_HOME}/ext process.URLInfoUpdater -crawlId ${crawlId}
echo ""

echo ""
echo "########## INLINKS DATA UPDATE JOB ##########"
echo "${PEPPER_HOME}/runtime/local/bin/nutch inlinkupdater -crawlId ${crawlId}"
${PEPPER_HOME}/runtime/local/bin/nutch inlinkupdater -crawlId ${crawlId}
echo ""

########## STORAGE BACKUP JOB END ##########

