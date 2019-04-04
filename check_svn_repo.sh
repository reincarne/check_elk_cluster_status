#!/bin/bash
#This script will check if svn repo is accessible
#Author: Alex Ledovski

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
USER=XXX #add username here
PASS= XXX #add password here
SERVER=$1
REPO_LIST=$2
REPO_LIST_ARR=()
STATUS_BAD_ARR=()
STATUS_GOOD_ARR=()
FLAG=0

IFS='#' read -ra REPO_LIST_ARR <<< "$REPO_LIST" #break the input by #delimiter
for repo in "${REPO_LIST_ARR[@]}"; do #for each of the repos, check if accessible. Based on the exit code, the data will be saved in a new array.
        out=`/usr/bin/svn info --username $USER --password $PASS svn://$SERVER/$repo/ 2>/dev/null`
        EXIT=$?
        if [ $EXIT -eq 1 ]; then
                STATUS_BAD_ARR=("${STATUS_BAD_ARR[@]}" "$repo")
                STATUS_BAD_ARR=("${STATUS_BAD_ARR[@]}" "$(echo "${out}" | tail -1)")
                FLAG=1
        else
                STATUS_GOOD_ARR=("${STATUS_GOOD_ARR[@]}" "$repo")
                STATUS_GOOD_ARR=("${STATUS_GOOD_ARR[@]}" "$(echo "${out}" | tail -1)")
        fi
done

if [ $FLAG -eq 1 ]; then
        echo "CRITICAL - Problem with one of the repos. See extended info"
        arrLength=${#STATUS_BAD_ARR[@]}
        counter=0

        while [ $counter -lt $arrLength ]; do
                let counter=counter+1
                echo -e "${STATUS_BAD_ARR[$counter-1]} \t ${STATUS_BAD_ARR[$counter]}"
                let counter=counter+1
        done
        exit "${STATE_CRITICAL}"
else
        echo "OK - All repos are doing fine."
        arrLength=${#STATUS_GOOD_ARR[@]}
        counter=0

        while [ $counter -lt $arrLength ]; do
                let counter=counter+1
                echo -e "${STATUS_GOOD_ARR[$counter-1]} \t ${STATUS_GOOD_ARR[$counter]}"
                let counter=counter+1
        done
        exit "${STATE_OK}"
fi

