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
	
PID_FILE="${PEPPER_HOME}/shell/pid/${crawlId}.pid"

if [ -f $PID_FILE ];
	then
		kill -9 `cat $PID_FILE`

		while kill -0 `cat $PID_FILE` >/dev/null 2>&1
			do
				sleep 1
			done

		echo "PROCESS STOP SUCCESS [crawlId : ${crawlId}]"
		rm -r $PID_FILE
	else
		echo "INVALID PID FILE! (NOT CREATED OR ALREADY REMOVED) [crawlId : ${crawlId}]"
	fi

########## REMOVE STORAGE START ##########

echo ""
echo "########## REMOVE STORAGE INFO ##########"
echo "java -cp ${PEPPER_HOME}/ext process.StorageRemover -crawlId ${crawlId}"
java -cp ${PEPPER_HOME}/ext process.StorageRemover -crawlId ${crawlId}
echo ""

########## REMOVE STORAGE START ##########
