#!/usr/bin/env bash
#
#   Script to run fruit-basket, primarily from docker
#
#   Expects
#   /fruit to be mounted
#   /fruit/Data to contain the file(s) to process
#   Script to live in /usr/bin/fruit-basket.sh
#

if [[ -d /fruit && -x /usr/bin/fruit-basket.sh && -d /fruit/Data ]]; then
    for i in /fruit/Data/*csv ; do
        /usr/bin/fruit-basket.sh $i
        sleep 1
    done
else
    echo "Problem with setup of /fruit or /usr/bin/fruit-basket.sh"
    ls -l /fruit
    ls -l /fruit/Data
    ls -l /usr/bin/fruit-basket.sh

fi
