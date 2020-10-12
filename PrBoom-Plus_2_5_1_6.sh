#!/bin/bash
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

DOOM_CPU_MASK=03
DOOM_HOME_DIR="/media/fat/Doom"
DOOM_EXE_NAME="prboom-plus"
DOOM_OPTIONS=""
DOOM_LIB_PATH="$DOOM_HOME_DIR/arm-linux-gnueabihf:$DOOM_HOME_DIR/arm-linux-gnueabihf/pulseaudio"


echo "Choose a .wad file: "

wadlist=($DOOM_HOME_DIR/*.wad)                              # Get list of .wad files in the Doom home dir
for i in "${!wadlist[@]}"
do
  wadfiles[i]="${wadlist[i]##*/}"                           # Get only the filesnames
  echo $((i+1))" -" "${wadfiles[i]}"                        # Add 1 to the array index so the user can choose starting with 1, rather than 0
done

read -p "Choice: " wadchoice

DOOM_OPTIONS="$DOOM_OPTIONS ${wadfiles[((wadchoice-1))]}"   # Add wad name to $DOOM_OPTIONS but subtract 1 since we added one earlier


echo "Setting Video mode..."
vmode -r 640 480 idx8

echo "Setting library path..."
echo $LD_LIBRARY_PATH
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$DOOM_LIB_PATH"

echo "Setting Doom HOME path..."
export HOME="$DOOM_HOME_DIR"

cd $DOOM_HOME_DIR
echo "Starting PrBoom-Plus :)"
taskset $DOOM_CPU_MASK "$DOOM_HOME_DIR/$DOOM_EXE_NAME" $DOOM_OPTIONS
