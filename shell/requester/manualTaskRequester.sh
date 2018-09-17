#!/bin/bash

PEPPER_HOME="/pepper/haena-pepper-1.0.0"

echo "PEPPER_HOME : ${PEPPER_HOME}"

echo ""
echo "########## MANUAL TASK REQUESTER START ##########"
echo "TIME : $(date +%Y)-$(date +%m)-$(date +%d) $(date +%H):$(date +%M):$(date +%S)"
echo "java -cp ${PEPPER_HOME}/ext process.ManualTaskRequester"
java -cp ${PEPPER_HOME}/ext process.ManualTaskRequester 
echo "########## MANUAL TASK REQUESTER END ##########"
echo ""

