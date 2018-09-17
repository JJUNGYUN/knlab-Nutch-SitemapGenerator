#!/bin/bash
depth=$1
./runtime/local/bin/nutch crawl urls -depth $depth
