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

# Find the newest mp4 of the newest project
newest_project=$(ls -td $SLING_ROOT_FOLDER/* | head -n1)
if [[ -z $newest_project ]]; then
   echo "No project folders found in $SLING_ROOT_FOLDER"
   exit 1
fi
echo "Newest project: $newest_project"

# If you want to search for the newest .mp4 file in sub dirs other than the
# "Program_Recordings" sub directory then comment out the next
# line.
recordings_folder="Program_Recordings"

newest_mp4=$(find $newest_project/$recordings_folder -type f -print0 | xargs -0 stat -f "%m %N" | sort -rn | head -1 | cut -f2- -d" ")
if [[ -z $newest_mp4 ]]; then
   echo "No .mp4 files found in $newest_project"
   exit 1
fi
echo "Newest mp4: $newest_mp4"

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

# Remove the oldest project folder that is over 2 weeks old
oldest_project=$(ls -rtd $SLING_ROOT_FOLDER/* | head -n1)
oldest_project_ts=$(stat -f "%m" $oldest_project)
now=$(date +%s)
let two_weeks=2*7*24*60*60
let two_weeks_ago_ts=now-two_weeks
if (( oldest_project_ts < two_weeks_ago_ts )); then
   rm -r $oldest_project
   echo "Removed $oldest_project"
else
   echo "There are no projects older than 2 weeks to remove"
fi
