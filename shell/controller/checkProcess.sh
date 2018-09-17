#!/bin/bash

PEPPER_HOME="/pepper/haena-pepper-1.0.0"

ps -ef | grep crawlId | awk '$18 == "-crawlId" {print $19}'
