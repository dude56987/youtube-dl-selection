########################################################################
# Build the youtube-dl-selection package
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
########################################################################
show:
	echo 'Run "make install" as root to install program!'
run:
	bash youtube-dl-selection.sh
install: build
	sudo gdebi --no youtube-dl-selection_UNSTABLE.deb
uninstall:
	sudo apt-get purge youtube-dl-selection
installed-size:
	du -sx --exclude DEBIAN ./debian/
build:
	sudo make build-deb;
build-deb:
	mkdir -p debian;
	mkdir -p debian/DEBIAN;
	mkdir -p debian/usr;
	mkdir -p debian/usr/bin;
	mkdir -p debian/usr/share/applications;
	# copy over the executables
	cp -vf youtube-dl-selection.sh debian/usr/bin/youtube-dl-selection
	cp -vf youtube-dl-queue.sh debian/usr/bin/youtube-dl-queue
	cp -vf youtube-dl-recover.sh debian/usr/bin/youtube-dl-recover
	# copy over the launchers
	cp -vf youtube-dl-selection.desktop debian/usr/share/applications/youtube-dl-selection.desktop
	cp -vf youtube-dl-recover.desktop debian/usr/share/applications/youtube-dl-recover.desktop
	# make the programs executable for everyone
	chmod ugo+x ./debian/usr/bin/*
	chmod go-rw ./debian/usr/bin/*
	chmod u+rw ./debian/usr/bin/*
	# Create the md5sums file
	find ./debian/ -type f -print0 | xargs -0 md5sum > ./debian/DEBIAN/md5sums
	# cut filenames of extra junk
	sed -i.bak 's/\.\/debian\///g' ./debian/DEBIAN/md5sums
	sed -i.bak 's/\\n*DEBIAN*\\n//g' ./debian/DEBIAN/md5sums
	sed -i.bak 's/\\n*DEBIAN*//g' ./debian/DEBIAN/md5sums
	rm -v ./debian/DEBIAN/md5sums.bak
	# figure out the package size
	du -sx --exclude DEBIAN debian/ > Installed-Size.txt
	# copy over package data
	cp -rv debdata/. debian/DEBIAN/
	# fix permissions in package
	chmod -Rv 775 debian/DEBIAN/
	chmod -Rv ugo+r debian/
	chmod -Rv go-w debian/
	chmod -Rv u+w debian/
	# build the package
	dpkg-deb --build debian
	cp -v debian.deb youtube-dl-selection_UNSTABLE.deb
	rm -v debian.deb
	rm -rv debian
