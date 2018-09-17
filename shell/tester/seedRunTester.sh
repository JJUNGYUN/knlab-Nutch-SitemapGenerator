#!/bin/bash

help()
{
	echo "Usage : $0 -crawlId [crawlId] -crawlDepth [crawlDepth]"
}

idx=1
crawlId=$2
crawlDepth=$4

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

PEPPER_HOME="/pepper/haena-pepper-1.0.0"

echo "PEPPER_HOME : ${PEPPER_HOME}"

########## SEED RUN JOB START ##########

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

########## SEED RUN JOB END ##########

########## RUN JOB START ##########

while [ ${idx} -le ${crawlDepth} ]
do

	echo ""
	echo "########## RUN JOB [ ${idx} DEPTH / ${crawlDepth} DEPTH ] START ##########"
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
	echo "########## RUN JOB [ ${idx} DEPTH / ${crawlDepth} DEPTH ] END ##########"
	echo ""

	idx=$((${idx}+1))	

done

########## RUN JOB END ##########

