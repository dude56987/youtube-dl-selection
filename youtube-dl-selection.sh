#! /bin/bash
########################################################################################
# Send highlighted text to youtube-dl as a argument
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
cd ~/Downloads;
# grab the clipboard selection into a variable
selection=$(xsel -o)
# figure out the tile of the selected video
title=$(youtube-dl --get-title $selection)
# get the file path and escape the white spaces
filePath="$(youtube-dl --get-filename $selection)"
# send a notification
message="Added '$title' to download queue..."
notify-send -i folder-download-symbolic "$message" || echo "$message"
# add task spooler task for youtube-dl-selection, set the id from the output
sem --fg --retries 10 --no-notice --ungroup --jobs 3 --id downloadQueue "youtube-dl -c $selection"
# check if the file was successfully downloaded by checking if the file exists
# now this works because youtube-dl generates .part files during the download
if [[ -f "$HOME/Downloads/$filePath" ]];then
	# set the return message to success or failure, use a success icon or failure icon in notification
	message="SUCCESS: Download of '$title' complete!"
	icon="checkbox-checked-symbolic"
else
	message="FAILURE: Download of '$title' failed!"
	icon="computer-fail-symbolic"
fi
# send the properly formatted return message with the correct icon
notify-send -i $icon "$message" || dialog --msgbox "$message" 5 21 || echo "$message"
########################################################################################
