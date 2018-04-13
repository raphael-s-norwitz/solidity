#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Bash script to run commandline Solidity tests.
#
# The documentation for solidity is hosted at:
#
#     https://solidity.readthedocs.org
#
# ------------------------------------------------------------------------------
# This file is part of solidity.
#
# solidity is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# solidity is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with solidity.  If not, see <http://www.gnu.org/licenses/>
#
# (c) 2016 solidity contributors.
#------------------------------------------------------------------------------

set -e

REPO_ROOT=$(cd $(dirname "$0")/.. && pwd)
echo $REPO_ROOT
SOLC="$REPO_ROOT/build/solc/solc"

FULLARGS="--optimize --ignore-missing --combined-json abi,asm,ast,bin,bin-runtime,clone-bin,compact-format,devdoc,hashes,interface,metadata,opcodes,srcmap,srcmap-runtime,userdoc"

echo "Checking that the bug list is up to date..."
# "$REPO_ROOT"/scripts/update_bugs_by_version.py

echo "Checking that StandardToken.sol, owned.sol and mortal.sol produce bytecode..."
output=$("$REPO_ROOT"/build/solc/solc --bin "$REPO_ROOT"/std/*.sol 2>/dev/null | grep "ffff" | wc -l)
test "${output//[[:blank:]]/}" = "3"

function printTask() { echo "$(tput bold)$(tput setaf 2)$1$(tput sgr0)"; }

function printError() { echo "$(tput setaf 1)$1$(tput sgr0)"; }

function Async_sub()
{
    local output failed
    local f=$1
    #echo "$f"    
    set +e
    output=$( ("$SOLC" $FULLARGS $f) 2>&1 )
    failed=$?
    set -e

    if [ $failed -ne 0 ]
    then
        printError "Compilation failed on:"
    	echo "$output"
    	printError "While calling:"
    	echo "\"$SOLC\" $FULLARGS $files"
    	printError "Inside directory:"
    	pwd
    	false
    fi
}

function compileAsync()
{
    for f in *.sol; do Async_sub "$f" & done; wait
}

#simply using dividend + remainder at the end
#TODO: is there way to split it optimally NP-complete problem?
#e.g. 10 in 2,2,3,3 instead of 2,2,2,4
function compileSplitAsync()
{
    #TODO:timing is not accurate if includes wc process everytime
    FILECOUNT=$(ls *.sol | wc -l)
    if [ $FILECOUNT -eq 1 ]
    then
        compileFull *.sol */*.sol
    else
        local files=(*.sol)
	#echo "$files"
        local file_tmp=()
	CPUCOUNT=$(grep -c ^processor /proc/cpuinfo)
	let ct=$FILECOUNT/$CPUCOUNT
	#NUMPER=$($FILECOUNT / $CPUCOUNT)
	#echo "$FILECOUNT"
	#echo "$CPUCOUNT"
	#echo "$ct"
	declare -i tmp
	declare -i i
	tmp=0
	i=1
	while [ $i -lt $CPUCOUNT ] 
	do
	    local subset=${files[@]:$tmp:$ct}
	    #echo "$subset"
	    file_tmp+=("$subset")
	    tmp+=$ct
	    i+=1	
	done
	#echo "tmp after"
	#echo "$tmp"
        local end=${files[@]:$tmp}
	file_tmp+=("$end")
        #echo "${file_tmp[1]}"
	for f in $file_tmp; do Async_sub "$f" & done; wait 
   fi
}

function compileFullIndividualFile()
{
    for f in *.sol
    do
        #echo "$f"
	local output failed

	set +e
    	output=$( ("$SOLC" $FULLARGS $f) 2>&1 )
    	failed=$?
    	set -e

    	if [ $failed -ne 0 ]
   	then
	    printError "Compilation failed on:"
	    echo "$output"
	    printError "While calling:"
	    echo "\"$SOLC\" $FULLARGS $files"
  	    printError "Inside directory:"
	    pwd
	    false
        fi
   done
}


function compileFull()
{
    local files="$*"
    local output failed
    #echo "$files"
    set +e
    output=$( ("$SOLC" $FULLARGS $files) 2>&1 )
    failed=$?
    set -e

    if [ $failed -ne 0 ]
    then
        printError "Compilation failed on:"
        echo "$output"
        printError "While calling:"
        echo "\"$SOLC\" $FULLARGS $files"
        printError "Inside directory:"
        pwd
        false
    fi
}

function compileWithoutWarning()
{
    local files="$*"
    local output failed

    set +e
    output=$("$SOLC" $files 2>&1)
    failed=$?
    # Remove the pre-release warning from the compiler output
    output=$(echo "$output" | grep -v 'pre-release')
    echo "$output"
    set -e

    test -z "$output" -a "$failed" -eq 0
}

printTask "Testing unknown options..."
(
    set +e
    output=$("$SOLC" --allow=test 2>&1)
    failed=$?
    set -e

    if [ "$output" == "unrecognised option '--allow=test'" ] && [ $failed -ne 0 ] ; then
	echo "Passed"
    else
	printError "Incorrect response to unknown options: $STDERR"
	exit 1
    fi
)

printTask "Compiling various other contracts and libraries..."
time (
cd "$REPO_ROOT"/test/compilationTests/
for dir in *
do
    if [ "$dir" != "README.md" ]
    then
        echo " - $dir"
        cd "$dir"
        #compileFull *.sol */*.sol
        compileSplitAsync
	#compileAsync
	#compileFullIndividualFile
	cd ..
    fi
done
)

printTask "Compiling all files in std and examples..."
time (
for f in "$REPO_ROOT"/std/*.sol
do
    echo "$f"
    compileWithoutWarning "$f"
done
)
printTask "Compiling all examples from the documentation..."
TMPDIR=$(mktemp -d)
time (
    set -e
    cd "$REPO_ROOT"
    REPO_ROOT=$(pwd) # make it absolute
    cd "$TMPDIR"
    "$REPO_ROOT"/scripts/isolate_tests.py "$REPO_ROOT"/docs/ docs
    for f in *.sol
    do
        echo "$f"
        compileFull "$TMPDIR/$f"
    done
)
rm -rf "$TMPDIR"
echo "Done."

printTask "Testing library checksum..."
echo '' | "$SOLC" --link --libraries a:0x90f20564390eAe531E810af625A22f51385Cd222
! echo '' | "$SOLC" --link --libraries a:0x80f20564390eAe531E810af625A22f51385Cd222 2>/dev/null

printTask "Testing long library names..."
echo '' | "$SOLC" --link --libraries aveeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeerylonglibraryname:0x90f20564390eAe531E810af625A22f51385Cd222

printTask "Testing overwriting files"
TMPDIR=$(mktemp -d)
(
    set -e
    # First time it works
    echo 'contract C {} ' | "$SOLC" --bin -o "$TMPDIR/non-existing-stuff-to-create" 2>/dev/null
    # Second time it fails
    ! echo 'contract C {} ' | "$SOLC" --bin -o "$TMPDIR/non-existing-stuff-to-create" 2>/dev/null
    # Unless we force
    echo 'contract C {} ' | "$SOLC" --overwrite --bin -o "$TMPDIR/non-existing-stuff-to-create" 2>/dev/null
)
rm -rf "$TMPDIR"

printTask "Testing soljson via the fuzzer..."
TMPDIR=$(mktemp -d)
(
    set -e
    cd "$REPO_ROOT"
    REPO_ROOT=$(pwd) # make it absolute
    cd "$TMPDIR"
    "$REPO_ROOT"/scripts/isolate_tests.py "$REPO_ROOT"/test/
    "$REPO_ROOT"/scripts/isolate_tests.py "$REPO_ROOT"/docs/ docs
    for f in *.sol
    do
        set +e
        "$REPO_ROOT"/build/test/tools/solfuzzer --quiet < "$f"
        if [ $? -ne 0 ]; then
            printError "Fuzzer failed on:"
            cat "$f"
            exit 1
        fi

        "$REPO_ROOT"/build/test/tools/solfuzzer --without-optimizer --quiet < "$f"
        if [ $? -ne 0 ]; then
            printError "Fuzzer (without optimizer) failed on:"
            cat "$f"
            exit 1
        fi
        set -e
    done
)
rm -rf "$TMPDIR"
echo "Commandline tests successful."
