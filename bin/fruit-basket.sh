#!/usr/bin/env bash
#   John F. Detke
#   jdetke@gmail.com
#   2020-08-11
#   Version=0.5
#   github?
#
#   requires single paramater name of a readable CSV file containing a head line
#   and subsequent data lines with 4 comma separated fields. The fields are:
#   fruit-type,age-in-days,characteristic1,characteristic2
#
#   Writes to standard out a report:
#   Total count of all fruits in the CVS-file
#   Total count of distinct fruit types in the basket
#   The fruit type and age of the oldest fruit in the basket in days
#   Count of all fruits grouped by fruit types in descending order
#   Count of all fruits grouped by fruit type and all characteristics in descending order
#
#   Bash script to produce fruit basket report
#   written for GNU bash, version 5.0.18(1)-release (x86_64-apple-darwin19.5.0)
#
#   Uses and requires several utilities including:
#   awk, cat, grep, sed, sort, uniq
#   These are expected to be in the user $PATH
#
#   Testing
#   test.sh shows example invocations, and includes several tests
#   Sample input files are in Data/*.csv. Several are broken, on purpose, for testing.
#
#   Simple format checking is included, including:
#   Too few fields
#   Insufficient data (csv data file must be at least 2 lines long)
#
#   This was written as an excersize in a few hours. Optimazation was not a priority,
#   in part to avoid early optimazation and in part as requirements need refinement (such as,
#   will this be run with large data sets).
#
#   TODO:
#   Thoughts on possible improvements are listed here and tagged with TODO below.
#   This is likely not portable to older bash versions, and other Operating systems.
#   Use of utilities such as sed, would also need to be addressed if portability was required.
#   Paramater handling is basic, getopt(s) use would be a useful update.
#
#   Additional data checking:
#   fruit, chars should be string
#   Age should be a digit
#   Extra fields are ignored, could be flagged as a warning
#   fruits are assumed to be valid fruit names, e.g. not vegtables
#
#   Installation
#   Git clone (TODO: elaborate)
#   copy fruit-basket.sh (this file) to a location, set read and execute permission.
#   Example invocations:
#   /home/jdetke/bin/fruit-basket.sh /data/basket.csv
#

# Global variables
Oldest=0           # Marker for oldest fruit, in days. Assume no fruit will actually be 0 days old

declare -a FruitTypes       # Array to hold types of Fruit: Apple, Pear ...
declare -A FruitTypeCount   # Assoc Arry of count of each fruit type, e.g. FruitTypeCount[apple]=1
declare -A OldestFruit      # Assoc array to hold the oldest fruit, by type

#   Usage
usage() {
    iam=$(basename "$0")
    echo "Usage: ${iam} input.csv"
    echo "${iam} requires single paramater, the path to a CSV file with fruit data"
    echo " fruit-type,age-in-days,characteristic1,characteristic2"
}

#   Help, not currently used
help() {
    echo " takes as input a CSV file with 4 fields:"
    echo " fruit-type,age-in-days,characteristic1,characteristic2 "
    echo " Outputs a report"
    echo " Example: "
    echo " ./fruit-basket.sh Data/small-basket.csv "
}

print_fruit_types() {
    for key in "${!FruitTypes[@]}" ; do
        echo "${FruitTypes[$key]} "
    done
}

print_oldest_fruit() {
    # Print all the fruit that is $Oldest days old
    for key in "${!OldestFruit[@]}" ; do
        if [[ "${OldestFruit[$key]}" == "$Oldest" ]] ; then
            echo "$key: ${OldestFruit[$key]} "
        fi
    done
}

print_descending() {
    for index in ${!FruitTypeCount[*]} ; do
        echo "$index: ${FruitTypeCount[$index]}"
    done |sort -k2 -r
}

print_characteristics() {
    # Count of all fruits grouped by fruit type and all characteristics in descending order
    #
    # awk seperates fields by the comman
    #   then prints the 3 fields of interest
    #   sort is used to group lines
    #   uniq count similar lines
    #   but uniq prepends spaces, so sed strips them out
    cat "${datafile}" |grep -v 'fruit-type' | awk -F, '{print $1 ":  " $3","$4}' |sort|uniq -c| sed "s/^[ \t]*//"
}

readlines() {
   #    Main execution loop
   #    Read data file, line by line.
   #    Process each line, run some basic checks, and build data structures
   #
   # Setup init variables, with starting values
   linecount=0
   read=""
   age=""
   char1=""
   char2=""

   #
   # read file into array, processing each line as we go
   #
   while IFS=, read -r fruit age char1 char2
   do
       ((linecount++))
       # Test format here, should have 4, and only 4, fields
       if [[ ("$char1" == "") || ("$char2" == "")  ]]; then
           echo "Formating problem on line ${linecount}, expected 4 fields"
           exit 1
       fi

       # TODO: check format of header line

       if [[ ! "$linecount" == 1 ]] ; then  # Skip header line
           ((FruitTotal++))
           haveone="false"  # we have not found it yet
           for key in "${!FruitTypes[@]}" ; do
             if [[ "${FruitTypes[$key]}" == "$fruit" ]]; then
                 # We already have fruit of this type, update count
                 haveone="true"
                 #  TODO can this be moved to ++ notaction ??
                 newcount=${FruitTypeCount[$fruit]}
                 ((newcount++))
                 FruitTypeCount[$fruit]=$newcount
             fi
           done

           if [[ "${haveone}" == "false" ]]; then

               # We do not have one yet, so setup new type of fruit
               # add $fruit to FruitTypes
               ## echo "DEBUG new fruit $fruit"
               FruitTypes+=("$fruit")       # Add to Fruit Types
               FruitTypeCount[$fruit]=1     # This is the first one
               OldestFruit[$fruit]=$age     # So its the oldest one, as well
           fi

           # If this fruit is oldest, reset oldest variable
           #
           if [[ $age > $Oldest ]]; then
               Oldest=${age}
           fi
       fi
   done < "${datafile}"

   if [[ "${linecount}" < 2 ]]; then
       echo " $datafile is too short to contain any fruit data "
       exit 1
   fi
}

# Print report
print_report() {
    # For debugging: print_fruit_types

    echo "Total number of Fruit:"
    echo "${FruitTotal}"
    echo " "

    echo "Total types of fruit:"
    # print index
    echo "${#FruitTypes[*]}"    # Number of items in the array
    echo " "

    echo "Oldest fruit & age:"
    print_oldest_fruit
    echo " "

    echo "The number of each type of fruit in descending order:"
    print_descending
    echo " "

    echo "The various characteristics (count, color, shape, etc.) of each fruit by type:"
    print_characteristics
    echo " "

}

# Main entry point here
# require single parameter, which is the filename
    if [ "$#" -ne 1 ]; then
        usage
        exit 1
    else
        datafile=$1
    fi

#  Does the data file exist?
if [ ! -f "${datafile}" ] ; then
    echo "no such file: ${datafile} "
    exit 1
fi

#   Can we read it?
if [[ ! -r "${datafile}" ]] ; then
    echo "${datafile} is not readable, please add read perms and re-run"
    exit 1
fi

#   Passed basic checks, now process the data

readlines
print_report
