#!/usr/bin/env bash
#
#   John Detke
#   jdetke@gmail.com
#
#   simple script to run basic tests for bin/fruit-basket.sh
#   This should be run in the main directory for fruit-basket
#   with a bin directory for fruit-basket.sh and this script
#   and a Data directory that contains the test data.
#
#   The script is run, and expects certain tests to fail, and others to pass.
#   Minimal check at this point, e.g. the failed tests are only checked for return codes.
#   For small, medium, large tests, visual inspection of output is used (See TODO for how that can be improved)
#
#   TODO
#   test for existence of data files, exit with appropriate warning if they are not where expected
#   Deeper testing, looking for correct output.
#     One possibility would be to use pre-canned output, and compare actual output with that.
#     A simple way to start would be a checksum on the expected and actual outputs,
#     further development would be diffing them.
#   Breaking into functions

date
## echo "test with no args: -----------------"
## bin/fruit-basket.sh

## echo "test unreadable file: --------------"
## chmod u-r Data/unreadable-basket.csv
## bin/fruit-basket.sh Data/unreadable-basket.csv
## #   return perms, so git checkin will work
## chmod u+r Data/unreadable-basket.csv

#   Test simple case: one fruit
## bin/fruit-basket.sh Data/onefruit.csv

#   Short file
bin/fruit-basket.sh Data/broken-basket1.csv
if [[ "$?" != "1" ]] ; then
    echo "test 2 should have failed, but did not"
    exit 1
fi

#   Test 3: Wrong number of fields:
bin/fruit-basket.sh Data/broken-basket2.csv
if [[ "$?" != "1" ]] ; then
    echo "test 3 should have failed, but did not"
    exit 1
fi

#   Test 4: Contains not a fruit, which is *not* checked for here
bin/fruit-basket.sh Data/broken-basket3.csv

#   Test 5: Too many fields, extra field data  is ignored
#   Should produce a report with fruit "toomany"
bin/fruit-basket.sh Data/broken-basket4.csv


#   Test 6: Two fruit types that are old
#   Should produce a report with 2 old fruits
result=$(bin/fruit-basket.sh Data/twoold.csv |grep -c twoold2)
if [[ "$result" != "3" ]]; then
    echo "Test 6 failed, did not find the correct count of 'twoold2' in report output"
    exit 1
fi


#   TODO: compare actual with expected output for these, which sould all run fine

#   test 7, run with a small basket to check output.
bin/fruit-basket.sh Data/small-basket.csv
if [[ "$?" != "0" ]] ; then
    echo "test 7 failed"
    exit 1
fi

## Test 8, medium sized
bin/fruit-basket.sh Data/medium-basket.csv   # should have 2 types of fruit under 'old' report
if [[ "$?" != "0" ]] ; then
    echo "test 8 failed"
    exit 1
fi
## Test 9
## bin/fruit-basket.sh Data/large-basket.csv
if [[ "$?" != "0" ]] ; then
    echo "test 9 failed"
    exit 1
fi

