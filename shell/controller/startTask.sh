#!/bin/bash

help()
{
	echo "Usage : $0 [crawlId] [crawlDepth] [crawlJobName] [taskSeq] [cycleStackCnt]"
}

idx=1
crawlId=$1
crawlDepth=$2
crawlJobName=$3
taskSeq=$4
cycleStackCnt=$5

if [ -z ${crawlId} ]
	then
		help
		exit 0
	fi

if [ -z ${crawlDepth} ]
	then
		help
		exit 0
	fi

if [ -z ${crawlJobName} ]
	then
		help
		exit 0
	fi

if [ -z ${taskSeq} ]
	then
		help
		exit 0
	fi

if [ -z ${cycleStackCnt} ]
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


echo "nohup ${PEPPER_HOME}/shell/task/crawl.sh ${crawlId} ${crawlDepth} ${crawlJobName} ${taskSeq} ${cycleStackCnt} >/dev/null 2>&1 &"
nohup ${PEPPER_HOME}/shell/task/crawl.sh ${crawlId} ${crawlDepth} ${crawlJobName} ${taskSeq} ${cycleStackCnt} >/dev/null 2>&1 &
echo "$!" > $PID_FILE

echo ""
echo "########## CRAWL PROCESS START ##########"
echo ""

