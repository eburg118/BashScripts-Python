#!/usr/bin/python
# STUDENT -- The path to the Python interpreter on acad is /usr/bin/python
# python4_2016.sh -- ERIC BURGOS solution to assignment 4, CSC 352 Unix
#   Spring 2016. This program accepts a path to a DIRECTORY as its first
#   command line argument, followed by one or more string PATTERNs
#   as the remaining command line arguments.
#
#   It must verify that it has at least 2 initial command line arguments
#   (the DIRECTORY and at least one PATTERN), and that the DIRECTORY is
#   in fact a directory. If any of these conditions fails, report an error
#   TO STANDARD ERROR and exits the script with an exit status of 1.
#   Otherwise proceed:

import sys  # STUDENT: sys.argv is a list [] of command line arguments,
            # with the command name itself at sys.argv[0], and actual
            # arguments at sys.argv[1:], see shell3.py for examples.
            # Also, sys.exit(STATUS) exits the process with integer STATUS.
            # Use len(LISTORSTRING) to get the number of elements in any
            # list or tuple, or the number of characters in a string.
import os.path  # STUDENT: os.path.isdir(PATH) returns True if the PATH
                # is a directory (like [ -d $PATH ] in bash), see
                # https://docs.python.org/2/library/os.path.html
import subprocess # STUDENT:  You need to import subprocess for my
                  # runProcess(shellCommandLine) functio to work.
                  # Use my supplied function where you would use back-ticked
                  # `shellCommandLine` in a bash shell script.
lastExitStatus = 0  # runProcess sets lastExitStatus similar to $? in bash.
def runProcess(shellCommandLine):
    '''
    Run shellCommandLine via a child shell process and return its
    standard output string, placing the 0 or non-0 exit status of the
    child process into global variable lastExitStatus. If the child
    returns an exit status != 0, then print its stderr to sys.stderr,
    but DO NOT EXIT!
    # STUDENT, Note the addition of lastExitStatus to simulate $?.
    '''
    global lastExitStatus
    # The global statement is needed only in a function that modifies
    # lastExitStatus. You can use the variable without the global statement.
    p = subprocess.Popen(shellCommandLine, shell=True, stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
    out = p.stdout.read()
    err = p.stderr.read()
    lastExitStatus = p.wait()   # Wait for termination.
    if lastExitStatus != 0:     # Error status
        sys.stderr.write(err)   # Echo its standard error to mine.
    else:
        # It may have written to stderr, but then exited with a 0 status.
        err = err.strip()
        if len(err) > 0:
            sys.stderr.write(err)
    p.stdout.close()
    p.stderr.close()
    return out

#Search function that takes the DIRECTORY and PATTERN as function arguments
def search(DIRECTORY, PATTERN):

# Looks for files within the DIRECTORY specified and finds files that satisfy the PATTERN
# and then counts the number of files. The number of files is stored in patternFiles
    tempDir = runProcess('find ' + DIRECTORY).replace('\n', ' ')
    patternFiles = runProcess( 'file ' + tempDir + ' | egrep ' + PATTERN + ' | wc -l ')
    patternFiles = int(patternFiles.strip())
    NLL = 0
    NWW = 0
    NCC = 0

# If any files are found that satisfy the PATTERN.. continue
    if patternFiles > 0:
#Loops through list of files that satisfy PATTERN
        listFiles = runProcess('file ' + tempDir + ' | egrep ' + PATTERN + ' | cut -d":" -f1')
        listFiles = listFiles.split()
        for f in listFiles:
            # Counts the number of lines in a file and stores in a counter variable
            NL = runProcess('cat ' + f +  ' | wc -l')
            NL = int(NL.strip())
            NLL += NL
            # Counts the number of words in a file and stores in a counter variable
            NW = runProcess('cat ' + f +  ' | wc -w')
            NW = int(NW.strip())
            NWW += NW
            # Counts the number of characters/bytes in file and stores in a counter variable
            NC = runProcess('cat ' + f +  ' | wc -c')
            NC = int(NC.strip())
            NCC += NC
    # Returns counter variables to the main shell
    return (patternFiles, NLL, NWW, NCC)

def main():

    # Verifies that there are at least 2 command line arguments and that the
    # DIRECTORY($1) is actually a directory
    if len(sys.argv) < 3 or not os.path.isdir(sys.argv[1]):
        sys.stderr.write("ERROR: Must have at least 2 arguments and the first must be a Directory\n")
        sys.exit(1)
    #Loops, calls function and prints out results(variables)
    for pattern in sys.argv[2:]:
        fileCount, lineCount, wordCount, charCount = search(sys.argv[1], pattern)
        sys.stdout.write(pattern + " " + str(fileCount) + " files, " + str(lineCount) + " lines, " + str(wordCount) + " words, " + str(charCount) + " chars\n")
    sys.exit(0)
#Calls main function
if __name__ == "__main__":
    main()
