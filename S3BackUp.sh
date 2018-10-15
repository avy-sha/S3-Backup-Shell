#!/bin/bash

#******************************************************************************#
#Purpose of this bash script is to automatically back up folders, specified in
#	S3PathMaster.txt, to S3 on AWS.
#Create Date
#	14 OCT 2018
#Author
#	Abhinav Sharma
#VERSION
#	0.01
#******************************************************************************#

#function to quit bash if called
function uquit() {
	exit 1
}

#Grabbing current time as formatted per ls -lATr
NTIME=`date +%s`

#checking for the .aws file
if [ -e ~/.aws ]
then
	echo ".aws file found, preparing backup"
else
	echo "Please install the AWS CLI tool"
	uquit
fi

#Grabbing last updated time from S3PathMaster.txt
LTIME=`grep LASTUPDATETIME S3PathMaster.txt | cut -d":" -f2`
DTIME=$(($NTIME-$LTIME))
#Overwriting MASTERTIME if an argument is given
if [ "$#" -gt "0" ]
then
        MASTERTIME=0
else
	MASTERTIME=$(($NTIME-$DTIME))
fi
echo "Uploading files to S3 that have been modified in the past $DTIME seconds"

#Grabbing S3 bucket name from S3PathMaster.txt
S3BUCKET=`grep BUCKET S3PathMaster.txt | cut -d":" -f2`
echo "All backups will be added to the S3 bucket: $S3BUCKET"

#Grabbing directories to back up from S3PathMaster.txt
#BACKUPPATH=`grep PATH S3PathMaster.txt | cut -d":" -f2`
BACKUPPATH=`pwd`'/'
#echo $BACKUPPATH
#aws s3 cp $BACKUPPATH s3://$S3BUCKET$(dirname "${BACKUPPATH}")/
#Grabbing all directories and files in the list $BACKUPPATH

FILE=`find ${BACKUPPATH} -type f`
OIFS="$IFS"
IFS=$'\n'
echo $FILE
	for file in `find ${BACKUPPATH} -type f`
	do
		echo $file	
		CTIME=`date -r $file +%s`
		if [ "$CTIME" -gt "$MASTERTIME" ]
		then
			echo $file			
			aws s3 cp $file s3://$S3BUCKET$(dirname "${file}")/
		fi
	done
IFS="$OIFS"
#Updating the LASTUPDATETIME field in S3PathMaster.txt
sed -i "s/LASTUPDATETIME.*/LASTUPDATETIME:${NTIME}/" ./S3PathMaster.txt

