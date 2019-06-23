#!/bin/bash
#
# Script needed:
# 
# The goal is to find the newest MyProject-n folder.  Once found, 
# copy the newest .mp4 file from that folder to this directory 
# which may or may not yet exist:
# 
# /Users/projection/Movies/Manually Copied/<current date format yyyy-mm-dd>
# 
# And then find the oldest MyProject-n folder on the SlingStudio memory 
# card that is at least 2 weeks old, and delete the entire old MyProject-n 
# folder, leaving the newest ones alone.
# 
# NOTE: The folder names MyProject-1, MyProject-2, MyProject-3, etc 
# are inconsistently named so you can’t rely on that name of the hierarchy.
# All the other levels of hierarchy above and below are consistently named.

SLING_ROOT_FOLDER="/Volumes/SlingStudio/SlingStudio/SlingStudioProjects"
DESTINATION_ROOT_FOLDER="/Users/projection/Movies/Manually Copied"
RECORDINGS_FOLDER="Program_Recordings"
PROJECT_FIELD=6

# Find the newest mp4 in all Program_Recordings folders
newest_mp4=$(ls -t $SLING_ROOT_FOLDER/*/$RECORDINGS_FOLDER/*.mp4 | head -n1)
if [[ -z $newest_mp4 ]]; then
   echo "No .mp4 files found in any $RECORDINGS_FOLDER folders"
   exit 1
fi
echo "Newest mp4: $newest_mp4"

# Assume the newest project is that with the newest .mp4 file
newest_project=$(echo $newest_mp4 | cut -f $PROJECT_FIELD -d '/')
echo "Newest project: $newest_project"

# Copy mp4 to destination
ymd=$(date +%Y-%m-%d)
destination_folder="$DESTINATION_ROOT_FOLDER/$ymd"
mkdir -p $destination_folder
cp $newest_mp4 $destination_folder
if (($?)); then
   echo "Failed to copy $newest_mp4 to $destination_folder"
   exit 1
fi
echo "$newest_mp4 copied to $destination_folder"

# Find the oldest mp4 in all RECORDINGS_FOLDERs
oldest_mp4=$(ls -rt $SLING_ROOT_FOLDER/*/$RECORDINGS_FOLDER/*.mp4 | head -n1)
if [[ -z $oldest_mp4 ]]; then
   echo "No .mp4 files found in any $RECORDINGS_FOLDER folders"
   exit 1
fi
echo "Oldest mp4: $oldest_mp4"

# Assume the oldest project is that with the oldest .mp4 file
oldest_project=$(echo $oldest_mp4 | cut -f $PROJECT_FIELD -d '/')
echo "Oldest project: $oldest_project"

# Remove the oldest project folder that is over 2 weeks old
oldest_mp4_ts=$(stat -f "%m" $oldest_mp4)
now=$(date +%s)
let two_weeks=2*7*24*60*60
let two_weeks_ago_ts=now-two_weeks
if (( oldest_mp4_ts < two_weeks_ago_ts )); then
   rm -r $oldest_project
   echo "Removed $oldest_project"
else
   echo "There are no projects older than 2 weeks to remove"
fi
