#!/bin/bash

help()
{
	echo "Usage : $0 -crawlId [crawlId] -taskSeq [taskSeq] -keyword [keyword] -extType [extType]"
}

crawlId=$2
taskSeq=$4
keyword=$6
extType=$8

if [ -z ${crawlId} ]
	then
		help
		exit 0
	fi

if [ -z ${taskSeq} ]
	then
		help
		exit 0
	fi

if [ -z ${keyword} ]
	then
		help
		exit 0
	fi

if [ -z ${extType} ]
	then
		help
		exit 0
	fi

PEPPER_HOME="/pepper/haena-pepper-1.0.0"
echo "PEPPER_HOME : ${PEPPER_HOME}"

PID_FILE="${PEPPER_HOME}/shell/pid/${crawlId}.pid"

if [ -f $PID_FILE ];
	then
		kill -15 `cat $PID_FILE`

		while kill -0 `cat $PID_FILE` >/dev/null 2>&1
			do
				sleep 1
			done
		
		echo "PROCESS STOP SUCCESS [crawlId : ${crawlId}]"
		rm -r $PID_FILE
	else
		echo "INVALID PID FILE! (NOT CREATED OR ALREADY REMOVED) [crawlId : ${crawlId}]"
	fi

echo "nohup ${PEPPER_HOME}/shell/task/update.sh -crawlId ${crawlId} -taskSeq ${taskSeq} -keyword ${keyword} -extType ${extType} >/dev/null 2>&1 &"
nohup ${PEPPER_HOME}/shell/task/update.sh -crawlId ${crawlId} -taskSeq ${taskSeq} -keyword ${keyword} -extType ${extType} >/dev/null 2>&1 &
echo "$!" > $PID_FILE

echo ""
echo "########## UPDATE PROCESS START ##########"
echo ""

