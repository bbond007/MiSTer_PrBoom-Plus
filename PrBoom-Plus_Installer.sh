#!/bin/bash
#------------------------------------------------------------------------------
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Functions 'setupCURL' and 'installDEBS' are Copyright 2019 
# Alessandro "Locutus73" Miele
#------------------------------------------------------------------------------

ALLOW_INSECURE_SSL=TRUE
INSTALL_DIR=/media/fat/Doom
SCRIPTS_DIR=/media/fat/Scripts
GITHUB_REPO=https://github.com/bbond007/MiSTer_PrBoom-Plus/raw/master
GITHUB_DEB_REPO="$GITHUB_REPO/DEBS"
INTERNET_CHECK=https://github.com
VERBOSE_MODE=FALSE
INSTALL_MULTIPLAYER=FALSE
FIX_MISSING_LIB_VERSION_INFO=FALSE

#These options probably should not be changed...
DELETE_JUNK=TRUE
DO_INSTALL=TRUE

#------------------------------------------------------------------------------
function setupCURL
{
	[ ! -z "${CURL}" ] && return
	CURL_RETRY="--connect-timeout 15 --max-time 120 --retry 3 --retry-delay 5"
	# test network and https by pinging the most available website 
	SSL_SECURITY_OPTION=""
	curl ${CURL_RETRY} --silent $INTERNET_CHECK > /dev/null 2>&1
	case $? in
		0)
			;;
		60)
			if [[ "${ALLOW_INSECURE_SSL}" == "TRUE" ]]
			then
				SSL_SECURITY_OPTION="--insecure"
			else
				echo "CA certificates need"
				echo "to be fixed for"
				echo "using SSL certificate"
				echo "verification."
				echo "Please fix them i.e."
				echo "using security_fixes.sh"
				exit 2
			fi
			;;
		*)
			echo "No Internet connection"
			exit 1
			;;
	esac
	CURL="curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --location"
	CURL_SILENT="${CURL} --silent --fail"
}

#------------------------------------------------------------------------------
function installGithubDEBS () {
	GITHUB_DEB_REPOSITORIES=( "${@}" )
	TEMP_PATH="/tmp"
	for GITHUB_DEB_REPOSITORY in "${GITHUB_DEB_REPOSITORIES[@]}"; do
		OLD_IFS="${IFS}"
		IFS="|"
		PARAMS=(${GITHUB_DEB_REPOSITORY})
		TEMP_PATH="/tmp"
		DEB_URL="${PARAMS[0]}"
		DEB_NAME="${PARAMS[1]}"
		ARC_FILES="${PARAMS[2]}"
		STRIP_CPT="${PARAMS[3]}"
        	DEST_DIR="${PARAMS[4]}"
		IFS="${OLD_IFS}"
		if [ "$VERBOSE_MODE" = "TRUE" ];
		then
 			echo "DEB_URL   --> $DEB_URL"
			echo "DEB_NAME  --> $DEB_NAME"
			echo "ARC_FILES --> $ARC_FILES"
			echo "STRIP_CPT --> $STRIP_CPT"
			echo "DEST_DIR  --> $DEST_DIR"	
		else
			echo "Downloading --> ${DEB_NAME}"
		fi
		${CURL} -L "${DEB_URL}/${DEB_NAME}" -o "${TEMP_PATH}/${DEB_NAME}"
		[ ! -f "${TEMP_PATH}/${DEB_NAME}" ] && echo "Error: no ${TEMP_PATH}/${DEB_NAME} found." && exit 1
		echo "Extracting ${ARC_FILES}"
		ORIGINAL_DIR="$(pwd)"
		cd "${TEMP_PATH}"
		rm data.tar.xz data.tar.gz > /dev/null 2>&1	
		ar -x "${TEMP_PATH}/${DEB_NAME}" data.tar.*
		cd "${ORIGINAL_DIR}"
		rm "${TEMP_PATH}/${DEB_NAME}"
		mkdir -p "${DEST_DIR}"
		if [ -f "${TEMP_PATH}/data.tar.xz" ]
		then
			tar -xJf "${TEMP_PATH}/data.tar.xz" --wildcards --no-anchored --strip-components="${STRIP_CPT}" -C "${DEST_DIR}" "${ARC_FILES}"
			rm "${TEMP_PATH}/data.tar.xz" > /dev/null 2>&1
		else
		  	[ ! -f "${TEMP_PATH}/data.tar.gz" ] && echo "Error: no ${TEMP_PATH}/data.tar found." && exit 1
		  	tar -xzf "${TEMP_PATH}/data.tar.gz" --wildcards --no-anchored --strip-components="${STRIP_CPT}" -C "${DEST_DIR}" "${ARC_FILES}"
		  	rm "${TEMP_PATH}/data.tar.gz" > /dev/null 2>&1
		fi
	done
}

#------------------------------------------------------------------------------
setupCURL
if [ "$DO_INSTALL" = "TRUE" ];
then
	echo "Beginning Install..."
	if [ -d "$INSTALL_DIR" ];
	then
		echo "ScummVM install directory found :)"
	else
		echo "ScummVM install directory not found :("
		echo "Creating --> $INSTALL_DIR"
		mkdir $INSTALL_DIR
	fi
	
	if [ -d "$SCRIPTS_DIR" ];
	then
		echo "Scripts directory found :)"
	else
		echo "Scripts directory not found :("
		echo "Creating --> $SCRIPTS_DIR"
		mkdir $SCRIPTS_DIR
	fi
	
	echo "Downloading --> PrBoom-Plus_2_5_1_5.sh..."
	${CURL} -L "$GITHUB_REPO/PrBoom-Plus_2_5_1_5.sh" -o "$SCRIPTS_DIR/PrBoom-Plus_2_5_1_5.sh"
	
	installGithubDEBS "$GITHUB_DEB_REPO|prboom-plus_2.5.1.5_svn4462+dfsg1-1+b2_armhf.deb|prboom-plus*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libasyncns0_0.8-6_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libbsd0_0.7.0-2_armhf.deb|lib*|2|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libcaca0_0.99.beta19-2.1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libdirectfb-1.2-9_1.2.10.0-8+deb9u1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libdumb1_0.9.3-6+b3_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libflac8_1.3.2-3_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libfluidsynth1_1.1.6-2_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libffi6_3.2.1-9_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libgl1_1.1.0-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libglu1-mesa_9.0.0-2.1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libglvnd0_1.1.0-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libglx0_1.1.0-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libice6_1.0.9-2_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libjpeg62_6b2-3_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libmad0_0.15.1b-8+deb9u1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libmikmod3_3.3.11.1-4_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libopenal1_1.17.2-4+b2_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libpcre3_8.39-3_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libportmidi0_217-6_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libpulse0_10.0-1+deb9u1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libreadline6_6.3-8+b3_armhf.deb|lib*|2|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libsdl-image1.2_1.2.12-10_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libsdl-mixer1.2_1.2.12-15_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libsdl-net1.2_1.2.8-6_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libsdl1.2debian_1.2.15-10+b1_armhf.deb|lib*|3|$INSTALL_DIR" 
	installGithubDEBS "$GITHUB_DEB_REPO|libsdl2-2.0-0_2.0.2+dfsg1-6_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libsm6_1.2.3-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libsndfile1_1.0.28-6_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libsndio6.1_1.1.0-3_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libsndio7.0_1.5.0-3_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libsystemd0_215-17+deb8u7_armhf.deb|lib*|2|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libtinfo5_6.1+20181013-2_armhf.deb|lib*|2|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libtinfo6_6.1+20181013-2_armhf.deb|lib*|2|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libwayland-egl1_1.16.0-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libwayland-client0_1.16.0-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libwayland-cursor0_1.16.0-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libwebp6_0.6.1-2_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libwrap0_7.6.q-28_armhf.deb|lib*|2|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libx11-6_1.6.7-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libx11-xcb1_1.6.7-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxau6_1.0.8-1+b2_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxcb1_1.12-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxcursor1_1.2.0-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxdmcp6_1.1.2-3_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxext6_1.3.3-1+b2_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxfixes3_5.0.3-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxi6_1.7.9-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxinerama1_1.1.4-2_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxrandr2_1.5.1-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxrender1_0.9.10-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxss1_1.2.3-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxtst6_1.2.3-1_armhf.deb|lib*|3|$INSTALL_DIR"
	installGithubDEBS "$GITHUB_DEB_REPO|libxxf86vm1_1.1.4-1+b2_armhf.deb|lib*|3|$INSTALL_DIR"

	if [ "$INSTALL_MULTIPLAYER" = "TRUE" ];
	then
		installGithubDEBS "$GITHUB_DEB_REPO|prboom-plus-game-server_2.5.1.5_svn4462+dfsg1-1+b2_armhf.deb|prboom-plus*|3|$INSTALL_DIR"
		echo "Downloading --> PrBoom-Plus_2_5_1_5_Client.sh..."
		${CURL} -L "$GITHUB_REPO/PrBoom-Plus_2_5_1_5_Client.sh" -o "$SCRIPTS_DIR/PrBoom-Plus_2_5_1_5_Client.sh"
		echo "Downloading --> PrBoom-Plus_2_5_1_5_Host.sh..."
		${CURL} -L "$GITHUB_REPO/PrBoom-Plus_2_5_1_5_Host.sh" -o "$SCRIPTS_DIR/PrBoom-Plus_2_5_1_5_Host.sh"
	fi

	if [ "$FIX_MISSING_LIB_VERSION_INFO" = "TRUE" ];
	then
		installGithubDEBS "$GITHUB_DEB_REPO|libasound2_1.1.3-5_armhf.deb|lib*|3|$INSTALL_DIR"
		installGithubDEBS "$GITHUB_DEB_REPO|libdb5.3_5.3.28-12+deb9u1_armhf.deb|lib*|3|$INSTALL_DIR"
		installGithubDEBS "$GITHUB_DEB_REPO|libjack0_0.125.0-3_armhf.deb|lib*|3|$INSTALL_DIR"
		installGithubDEBS "$GITHUB_DEB_REPO|libjbig0_2.1-3.1_armhf.deb|lib*|3|$INSTALL_DIR"
		installGithubDEBS "$GITHUB_DEB_REPO|libncursesw6_6.1+20181013-2_armhf.deb|lib*|2|$INSTALL_DIR"
		installGithubDEBS "$GITHUB_DEB_REPO|libtiff5_4.0.10-4_armhf.deb|lib*|3|$INSTALL_DIR"		
		installGithubDEBS "$GITHUB_DEB_REPO|libzstd1_1.1.2-1_armhf.deb|lib*|3|$INSTALL_DIR"
	fi

	echo "Moving --> prboom-plus.wad"
	mv "$INSTALL_DIR/games/doom/prboom-plus.wad" $INSTALL_DIR

	echo "Moving --> libpcre.so.3.13.3"
	mv "$INSTALL_DIR/libpcre.so.3.13.3" "$INSTALL_DIR/arm-linux-gnueabihf"
	mv "$INSTALL_DIR/libpcre.so.3" "$INSTALL_DIR/arm-linux-gnueabihf"

	if [ "$DELETE_JUNK" = "TRUE" ];
	then
		echo "Deleting junk..."
		for JUNK_FILE in "bash-completion" "bug" "doc" "doc-base" "lib" "lintian"  "man" "share" "games" "applications" "icons" "libpcre.so.3*";
		do
			rm -rf "$INSTALL_DIR/$JUNK_FILE"
		done
	fi

	echo "Done in:"
	for i in 3 2 1;
	do
		echo "$i"
		sleep 1
	done
fi

