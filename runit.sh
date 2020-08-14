#!/usr/bin/env bash

if [[ ! -d /fruit ]] ; then
    echo "Problem with input dir, /fruit is not a directory"
    exit 1
fi

for i in /fruit/*csv ; do
    echo "Processing $i"
    /fruit/bin/fruit-basket.sh $i
    sleep 3
done
