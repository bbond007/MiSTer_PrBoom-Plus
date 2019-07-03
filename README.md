# MiSTer_PrBoom-Plus
PrBoom-Plus installer for the MiSTer FPGA platform
Install:

      (Run) --> PrBoom-Plus_Installer.sh
	  
Requirement(s):

Original DOOM.WAD, DOOM2.WAD or https://freedoom.github.io/ or ???

Multiplayer:

      - (Edit) --> PrBoom-Plus_Installer.sh
             
             INSTALL_MULTIPLAYER=TRUE

      - (Edit) --> PrBoom-Plus_2_5_1_5_Client.sh

             DOOM_HOST="192.168.1.158"
	
FluidSynth:

      - Start game and select FluidSynth audio (prboom-plus.cfg) will be created
	
      - (Edit) --> /media/fat/Doom/.prboom-plus/prboom-plus.cfg:

             snd_soundfont             "/media/fat/linux/soundfonts/SC-55.sf2"

