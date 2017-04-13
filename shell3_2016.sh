#!/bin/bash
# shell3_2016.sh -- ERIC BURGOS solution to assignment 3, CSC 352 Unix
#   Spring 2016. This program accepts a path to a DIRECTORY as its first
#   command line argument, followed by one or more string PATTERNs
#   as the remaining command line arguments.



function search()
{
# $1 DIRECTORY
# $2 PATTERN
# $3 Files that match PATTERN
# $4 Number of lines in file
# $5 Number of words in the file
# $6 Number of characters/bytes in the file

# Finds DIRECTORY from command line argument $1
tempDir=`find $DIRECTORY`


# Looks for files within the DIRECTORY specified and finds files that satisfy the PATTERN
# and then counts the number of files. The number of files is stored in patternFiles 
patternFiles=`file $tempDir | egrep $2 | wc -l` 

# Declaration of variables that will be used as counters
NLL=0
NWW=0
NCC=0

# If any files are found that satisfy the PATTERN.. continue
if [ $patternFiles -gt 0 ]  
then
    for f in `file $tempDir | egrep $2 | cut -d':' -f1`  #Loops through list of files that satisfy PATTERN
    do	
	# Counts the number of lines in a file and stores in a counter variable
	NL=`cat $f | wc -l`
	NLL=`expr $NLL + $NL`
	
	# Counts the number of words in a file and stores in a counter variable
	NW=`cat $f | wc -w`
	NWW=`expr $NWW + $NW`
	
	# Counts the number of characters/bytes in file and stores in a counter variable
	NC=`cat $f | wc -c`  
        NCC=`expr $NCC + $NC`
	
    done
fi

# Returns counter variables to the main shell code which calls the function
eval "$3=$patternFiles"
eval "$4=$NLL"
eval "$5=$NWW"
eval "$6=$NCC"

}

# Stores first command line argument in a variable called DIRECTORY
DIRECTORY=$1

# Verifies that there are at least 2 command line arguments and that the 
# DIRECTORY($1) is actually a directory 
if [ $# -lt 2 ]
then
    #Reports ERROR to std error and exits script with an exit satatus of 1
    echo "ERROR, there must be at least 2 command line arguments.">&2
    exit 1
elif [ ! -d "$DIRECTORY" ]
then
    echo "ERROR, the first command line argument must be a directory/directory path"
    exit 1
else

    # If command line argument conditions are passed this loop will run
    # while there are at least 2 command line arguments
    while [ $# -gt 1 ]
    do
	# Variables that hold counters that are being passed by the function
	# and that are being called by the main shell code
	tmpReg=0
	tmpNF=0
	tmpNL=0
	tmpNW=0
	tmpNC=0
	
	# Call to the function with arguments passed
	search $1 $2 tmpNF tmpNL tmpNW tmpNC
	
	# If the 3rd argument is greater than or equal to 0 then 
	# we echo whatever is stored in the variables passed by the function
	if [ $tmpNF -ge 0 ]
	then
	    
	    echo  "$2 $tmpNF files, $tmpNL lines, $tmpNW words, $tmpNC chars"	    
	fi
	
	# Shift parameters - 1
	shift
    done
fi