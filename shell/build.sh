#!/bin/bash

PEPPER_HOME="${PEPPER_HOME}"

echo "########## PEPPER BUILD START ##########"
echo "${PEPPER_HOME}/ant -v"
cd ${PEPPER_HOME}
ant -v
echo "########## PEPPER BUILD END ##########"
