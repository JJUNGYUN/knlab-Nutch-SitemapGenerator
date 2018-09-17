#!/bin/bash

echo "########## PEPPER SYSTEM BUFFER/CACHE FLUSH START ##########"

echo "echo 3 > /proc/sys/vm/drop_caches"
echo 3 > /proc/sys/vm/drop_caches

echo "sync"
sync

echo "########## PEPPER SYSTEM BUFFER/CACHE FLUSH END ##########"
