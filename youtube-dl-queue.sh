#! /bin/bash
########################################################################################
# Send a link to youtube-dl custom queue
# Copyright (C) 2017  Carl J Smith
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
########################################################################################
# grab the link to be passed into the queue
selection=$1
echo "Checking for download configuration at '$HOME/.youtube-dl-selection'"
# check for a user defined download path
if [ -f ~/.youtube-dl-selection ];then
	# load the config file
	downloadPath=$(cat ~/.youtube-dl-selection)
else
	# if no config exists create the default config
	downloadPath="$HOME/Downloads"
	# write the new config from the path variable
	echo "$downloadPath" > ~/.youtube-dl-selection
fi
echo "Download path set to '$downloadPath'"
# create the path if it does not exist, then move into it
mkdir -p $downloadPath
cd $downloadPath
# if the url is not a valid web address exit
echo "Scanning the selection for video links..."
if ! echo "$selection" | grep "http";then
	# build and display the error message to the user
	message="The selection '$selection' is not a valid url, youtube-dl-selection will now exit!"
	icon="computer-fail-symbolic"
	echo "$message"
	notify-send -i $icon "$message" || dialog --infobox "$message" 5 21
	# add failure message to the log
	echo "$message" | sed "s/, youtube-dl-selection will now exit!/.../g" >> $downloadPath/youtube-dl_FAILED.log
	exit
fi
# sleeping between website pulls with youtube-dl pervents being blocked or
# disconnected, saying processing is a lie but will probably cause less
# confusion
echo "Processing title..."
sleep 5
# figure out the tile of the selected video
title=$(youtube-dl --get-title $selection)
echo "Processing filename..."
sleep 5
# get the file path and escape the white spaces
fileName="$(youtube-dl --get-filename $selection)"
# send a notification
message="Added '$title' to download queue..."
echo "$message"
notify-send -i folder-download-symbolic "$message" || dialog --infobox "$message" 5 21
# add task spooler task for youtube-dl-selection, set the id from the output
# sleep for 15 seconds before download starts, this delays between failures, and delays after the above youtube-dl uses
sem --fg --retries 10 --no-notice --ungroup --jobs 3 --id downloadQueue "echo 'Processing...';sleep 15;youtube-dl -c $selection"
# check if the file was successfully downloaded by checking if the file exists
# now this works because youtube-dl generates .part files during the download
if [[ -f "$downloadPath/$fileName" ]];then
	# change the modification time so the last downloaded file will be listed as such in the filesystem
	touch "$downloadPath/$fileName"
	# set the return message to success or failure, use a success icon or failure icon in notification
	message="SUCCESS: Download of '$title' complete!"
	icon="checkbox-checked-symbolic"
else
	# add failed download links to a text file
	echo "$selection '$title' FAILED to download!" >> $downloadPath/youtube-dl_FAILED.log
	message="FAILURE: Download of '$title' failed!"
	icon="computer-fail-symbolic"
fi
# send the properly formatted return message with the correct icon
echo "$message"
notify-send -i $icon "$message" || dialog --infobox "$message" 5 21
########################################################################################
