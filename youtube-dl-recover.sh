#! /bin/bash
########################################################################################
# Add all items from the failed log back to the queue
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
# read the failure log if it exists
if [[ -f "$downloadPath/youtube-dl_FAILED.log" ]];then
	while read line;do
		# read each line of the error log and retry the failed links
		echo "youtube-dl-queue ${line[0]}"
		# launch the download
		youtube-dl-queue ${line[0]}
		if [[ -f "$downloadPath/youtube-dl_FAILED.log" ]];then
			# remove old log, if it has not been removed yet
			rm -v $downloadPath/youtube-dl_FAILED.log
		fi
	done < $downloadPath/youtube-dl_FAILED.log
else
	message="Failed to load any error log at '$downloadPath'"
	icon="computer-fail-symbolic"
fi
########################################################################################
echo $message
notify-send -i $icon "$message" || dialog --infobox "$message" 5 21
