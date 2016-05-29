#!/bin/bash
#
# calc_disk_usage.sh
# 2016 - ze.miguel.maria@gmail.com
#
# Program to find disk usage
# It creates disk-usage.txt with the information.
# It has color, so you can use it in other scripts like
#
# cat disk-usage.txt


# -- auxiliary function
# CalcCols calculates the bars needed to display the selected size.
# Arguments: Size, Char, Color
function CalcCols {
	local value=$1
	local char=$2
	local color=$3
	
	#change color
	lineInfo=$lineInfo$color
	
	COUNTER=0
	while [ "$COUNTER" -lt "$value" ]; do
	  lineInfo=$lineInfo$char
	  let COUNTER=COUNTER+1 
	done
}  


# variables configuration
backupFolder="/var/bak/"
wwwFolder="/var/www/"
cols=60 #columns of the graphic

#color setup
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PINK='\033[0;35m'
NC='\033[0m' # No Color

# chars for the graphic
FilledChar='\xB1'
FreeChar='~'


# get data from file system
diskTotal=$(df /home | sed -n '2p' | awk '{print $2}')
diskFree=$(df /home | sed -n '2p' | awk '{print $4}')
backupSize=$(du -s $backupFolder | awk '{print $1}')
wwwSize=$(du -s $wwwFolder | awk '{print $1}')
otherSize=$(($diskTotal-$diskFree-$backupSize-$wwwSize))
percentFree=$(($diskFree*100/$diskTotal))


# Calculations
wwwSizeCols=$(($wwwSize*$cols/$diskTotal)) 
wwwSizeHuman=$(awk "BEGIN {printf \"%.2f\n\", $wwwSize/1024/1024}")

backupSizeCols=$(($backupSize*$cols/$diskTotal)) 
backupSizeHuman=$(awk "BEGIN {printf \"%.2f\n\", $backupSize/1024/1024}")

otherSizeCols=$(($otherSize*$cols/$diskTotal))
otherSizeHuman=$(awk "BEGIN {printf \"%.2f\n\", $otherSize/1024/1024}")

freeSizeCols=$(($diskFree*$cols/$diskTotal))
freeSizeHuman=$(awk "BEGIN {printf \"%.2f\n\", $diskFree/1024/1024}")


#create the graphic

# initialize the var
lineInfo=""

# Calculate OS+Programs and change color to Blue
CalcCols $otherSizeCols $FilledChar $BLUE

# Calculate backup size and change color to Orange
CalcCols $backupSizeCols $FilledChar $ORANGE

# Calculate WWW size and change color to Pink
CalcCols $wwwSizeCols $FilledChar $PINK

# Calculate free size and change color to Green
CalcCols $freeSizeCols $FreeChar $GREEN


# resets color
lineInfo=$lineInfo$NC


# output to file disk_usage.sh
echo > disk_usage.txt
echo -e " Disk [$lineInfo]" >> disk_usage.txt
echo -e   " $BLUE\xB1$NC OS+Programs ("$otherSizeHuman" GB)" >> disk_usage.txt
echo -e   " $PINK\xB1$NC WWW files   ("$wwwSizeHuman" GB)" >> disk_usage.txt
echo -e " $ORANGE\xB1$NC Backups     ("$backupSizeHuman" GB)" >> disk_usage.txt
echo -e     " $GREEN~$NC Free space  ("$freeSizeHuman" GB)" >> disk_usage.txt
echo >> disk_usage.txt


# If low free space warn user
if [ "$percentFree" -lt "10" ]; then
  echo "Free disk space less than 10%!"
fi
