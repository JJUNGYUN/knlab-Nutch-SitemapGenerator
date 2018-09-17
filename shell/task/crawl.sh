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

if [ -z ${taskSeq} ]
	then
		help
		exit 0
	fi

if [ -z ${crawlJobName} ]
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

case "${crawlJobName}" in
	
	seedRunJob)

		########## SEED RUN PROCESS START ##########

		echo ""
		echo "########## TASK INFO UPDATE [TASK PROCESS : READY -> START] ##########"
		echo "java -cp ${PEPPER_HOME}/ext process.TaskUpdater -crawlId ${crawlId} -taskSeq ${taskSeq} -processStatus START"
		java -cp ${PEPPER_HOME}/ext process.TaskUpdater -crawlId ${crawlId} -taskSeq ${taskSeq} -processStatus START
		echo ""

		echo ""
		echo "########## TABLE CHECK JOB ##########"
		echo "java -cp ${PEPPER_HOME}/ext process.TableChecker -crawlId ${crawlId}"
		java -cp ${PEPPER_HOME}/ext process.TableChecker -crawlId ${crawlId} 
		echo ""

		echo ""
		echo "########## INJECT JOB ##########"
		echo "${PEPPER_HOME}/runtime/local/bin/nutch inject ${PEPPER_HOME}/urls/${crawlId}_seed.txt -crawlId ${crawlId}"
		${PEPPER_HOME}/runtime/local/bin/nutch inject ${PEPPER_HOME}/urls/${crawlId}_seed.txt -crawlId ${crawlId}
		echo ""

		echo ""
		echo "########## GENERATE JOB ##########"
		echo "${PEPPER_HOME}/runtime/local/bin/nutch generate -topN 1000 -crawlId ${crawlId}"
		${PEPPER_HOME}/runtime/local/bin/nutch generate -topN 1000 -crawlId ${crawlId}
		echo ""

		echo ""
		echo "########## FETCH JOB ##########"
		echo "${PEPPER_HOME}/runtime/local/bin/nutch fetch -all -crawlId ${crawlId}"
		${PEPPER_HOME}/runtime/local/bin/nutch fetch -all -crawlId ${crawlId}
		echo ""

		echo ""
		echo "########## PARSE JOB ##########"
		echo "${PEPPER_HOME}/runtime/local/bin/nutch parse -all -crawlId ${crawlId}"
		${PEPPER_HOME}/runtime/local/bin/nutch parse -all -crawlId ${crawlId}
		echo ""

		echo ""
		echo "########## UPDATEDB JOB ##########"
		echo "${PEPPER_HOME}/runtime/local/bin/nutch updatedb -crawlId ${crawlId}"
		${PEPPER_HOME}/runtime/local/bin/nutch updatedb -crawlId ${crawlId}
		echo ""

		########## SEED RUN PROCESS END ##########
		
		########## RUN PROCESS START ##########

		while [ ${idx} -le ${crawlDepth} ]
		
			do

				echo ""
				echo "########## RUN JOB [ ${idx} DEPTH / ${crawlDepth} DEPTH ] START ##########"
				echo ""

				echo ""
				echo "########## TASK HISTORY INFO UPDATE [CRAWL PROCESS START] ##########"
				echo "java -cp ${PEPPER_HOME}/ext process.TaskHistoryUpdater -crawlId ${crawlId} -crawlOrderCnt ${idx} -taskSeq ${taskSeq} -processStatus START"
				java -cp ${PEPPER_HOME}/ext process.TaskHistoryUpdater -crawlId ${crawlId} -crawlOrderCnt ${idx} -taskSeq ${taskSeq} -processStatus START
				echo ""

				echo ""
				echo "########## GENERATE JOB ##########"
				echo "${PEPPER_HOME}/runtime/local/bin/nutch generate -topN 1000 -crawlId ${crawlId}"
				${PEPPER_HOME}/runtime/local/bin/nutch generate -topN 1000 -crawlId ${crawlId}
				echo ""

				echo ""
				echo "########## FETCH JOB ##########"
				echo "${PEPPER_HOME}/runtime/local/bin/nutch fetch -all -crawlId ${crawlId}"
				${PEPPER_HOME}/runtime/local/bin/nutch fetch -all -crawlId ${crawlId}
				echo ""

				echo ""
				echo "########## PARSE JOB ##########"
				echo "${PEPPER_HOME}/runtime/local/bin/nutch parse -all -crawlId ${crawlId}"
				${PEPPER_HOME}/runtime/local/bin/nutch parse -all -crawlId ${crawlId}
				echo ""

				echo ""
				echo "########## UPDATEDB JOB ##########"
				echo "${PEPPER_HOME}/runtime/local/bin/nutch updatedb -crawlId ${crawlId}"
				${PEPPER_HOME}/runtime/local/bin/nutch updatedb -crawlId ${crawlId}
				echo ""

				echo ""
				echo "########## TASK HISTORY INFO UPDATE [CRAWL PROCESS END] ##########"
				echo "java -cp ${PEPPER_HOME}/ext process.TaskHistoryUpdater -crawlId ${crawlId} -crawlOrderCnt ${idx} -taskSeq ${taskSeq} -processStatus END"
				java -cp ${PEPPER_HOME}/ext process.TaskHistoryUpdater -crawlId ${crawlId} -crawlOrderCnt ${idx} -taskSeq ${taskSeq} -processStatus END
				echo ""

				########## STORAGE BACKUP PROCESS START ##########

				echo ""
				echo "########## URL INFO UPDATE JOB ##########"
				echo "java -cp ${PEPPER_HOME}/ext process.URLInfoUpdater -crawlId ${crawlId} -crawlOrderCnt ${idx} -cycleStackCnt ${cycleStackCnt}"
				java -cp ${PEPPER_HOME}/ext process.URLInfoUpdater -crawlId ${crawlId} -crawlOrderCnt ${idx} -cycleStackCnt ${cycleStackCnt}
				echo ""

				########## STORAGE BACKUP PROCESS END ##########

				echo ""
				echo "########## RUN JOB [ ${idx} DEPTH / ${crawlDepth} DEPTH ] END ##########"
				echo ""

				idx=$((${idx}+1))	

			done

		########## RUN PROCESS END ##########

		########## TASK INFO UPDATE START ##########

		echo ""
		echo "########## TASK INFO UPDATE [TASK PROCESS : START -> END] ##########"
		echo "java -cp ${PEPPER_HOME}/ext process.TaskUpdater -crawlId ${crawlId} -taskSeq ${taskSeq} -processStatus END"
		java -cp ${PEPPER_HOME}/ext process.TaskUpdater -crawlId ${crawlId} -taskSeq ${taskSeq} -processStatus END
		echo ""

		########## TASK INFO UPDATE END ##########

		########## TASK CYCLE STACK COUNT UPDATE START ##########

		echo ""
		echo "########## TASK CYCLE STACK COUNT UPDATE ##########"
		echo "java -cp ${PEPPER_HOME}/ext process.TaskCycleStackCntUpdater -taskSeq ${taskSeq} -cycleStackCnt ${cycleStackCnt}"
		java -cp ${PEPPER_HOME}/ext process.TaskCycleStackCntUpdater -crawlId ${crawlId} -taskSeq ${taskSeq} -cycleStackCnt ${cycleStackCnt}
		echo ""

		########## TASK CYCLE STACK COUNT UPDATE END ##########

	;;

	runJob)
		
		########## RUN PROCESS START ##########

		echo ""
		echo "########## TASK INFO UPDATE [TASK PROCESS : READY -> START] ##########"
		echo "java -cp ${PEPPER_HOME}/ext process.TaskUpdater -crawlId ${crawlId} -taskSeq ${taskSeq} -processStatus START"
		java -cp ${PEPPER_HOME}/ext process.TaskUpdater -crawlId ${crawlId} -taskSeq ${taskSeq} -processStatus START
		echo ""

		while [ ${idx} -le ${crawlDepth} ]
		
			do

				echo ""
				echo "########## RUN JOB [ ${idx} DEPTH / ${crawlDepth} DEPTH ] START ##########"
				echo ""

				echo ""
				echo "########## TASK HISTORY INFO UPDATE [CRAWL PROCESS START] ##########"
				echo "java -cp ${PEPPER_HOME}/ext process.TaskHistoryUpdater -crawlId ${crawlId} -crawlOrderCnt ${idx} -taskSeq ${taskSeq} -processStatus START"
				java -cp ${PEPPER_HOME}/ext process.TaskHistoryUpdater -crawlId ${crawlId} -crawlOrderCnt ${idx} -taskSeq ${taskSeq} -processStatus START
				echo ""

				echo ""
				echo "########## GENERATE JOB ##########"
				echo "${PEPPER_HOME}/runtime/local/bin/nutch generate -topN 1000 -crawlId ${crawlId}"
				${PEPPER_HOME}/runtime/local/bin/nutch generate -topN 1000 -crawlId ${crawlId}
				echo ""

				echo ""
				echo "########## FETCH JOB ##########"
				echo "${PEPPER_HOME}/runtime/local/bin/nutch fetch -all -crawlId ${crawlId}"
				${PEPPER_HOME}/runtime/local/bin/nutch fetch -all -crawlId ${crawlId}
				echo ""

				echo ""
				echo "########## PARSE JOB ##########"
				echo "${PEPPER_HOME}/runtime/local/bin/nutch parse -all -crawlId ${crawlId}"
				${PEPPER_HOME}/runtime/local/bin/nutch parse -all -crawlId ${crawlId}
				echo ""

				echo ""
				echo "########## UPDATEDB JOB ##########"
				echo "${PEPPER_HOME}/runtime/local/bin/nutch updatedb -crawlId ${crawlId}"
				${PEPPER_HOME}/runtime/local/bin/nutch updatedb -crawlId ${crawlId}
				echo ""

				echo ""
				echo "########## TASK HISTORY INFO UPDATE [CRAWL PROCESS END] ##########"
				echo "java -cp ${PEPPER_HOME}/ext process.TaskHistoryUpdater -crawlId ${crawlId} -crawlOrderCnt ${idx} -taskSeq ${taskSeq} -processStatus END"
				java -cp ${PEPPER_HOME}/ext process.TaskHistoryUpdater -crawlId ${crawlId} -crawlOrderCnt ${idx} -taskSeq ${taskSeq} -processStatus END
				echo ""

				########## STORAGE BACKUP PROCESS START ##########

				echo ""
				echo "########## URL INFO UPDATE JOB ##########"
				echo "java -cp ${PEPPER_HOME}/ext process.URLInfoUpdater -crawlId ${crawlId} -crawlOrderCnt ${idx} -cycleStackCnt ${cycleStackCnt}"
				java -cp ${PEPPER_HOME}/ext process.URLInfoUpdater -crawlId ${crawlId} -crawlOrderCnt ${idx} -cycleStackCnt ${cycleStackCnt}
				echo ""

				########## STORAGE BACKUP PROCESS END ##########

				echo ""
				echo "########## RUN JOB [ ${idx} DEPTH / ${crawlDepth} DEPTH ] END ##########"
				echo ""

				idx=$((${idx}+1))	

			done

		########## RUN PROCESS END ##########

		########## TASK INFO UPDATE START ##########

		echo ""
		echo "########## TASK INFO UPDATE [TASK PROCESS : START -> END] ##########"
		echo "java -cp ${PEPPER_HOME}/ext process.TaskUpdater -crawlId ${crawlId} -taskSeq ${taskSeq} -processStatus END"
		java -cp ${PEPPER_HOME}/ext process.TaskUpdater -crawlId ${crawlId} -taskSeq ${taskSeq} -processStatus END
		echo ""

		########## TASK INFO UPDATE END ##########

		########## TASK CYCLE STACK COUNT UPDATE START ##########

		echo ""
		echo "########## TASK CYCLE STACK COUNT UPDATE ##########"
		echo "java -cp ${PEPPER_HOME}/ext process.TaskCycleStackCntUpdater -taskSeq ${taskSeq} -cycleStackCnt ${cycleStackCnt}"
		java -cp ${PEPPER_HOME}/ext process.TaskCycleStackCntUpdater -crawlId ${crawlId} -taskSeq ${taskSeq} -cycleStackCnt ${cycleStackCnt}
		echo ""

		########## TASK CYCLE STACK COUNT UPDATE END ##########

	;;

esac

