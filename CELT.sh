#!/bin/bash
Version="1.0.0"
Name="CELT"
url="https://raw.githubusercontent.com/ActuallyFro/CELT/master/celt.sh"
CurrDir=`pwd`


defaultUser=`whoami`
MainMUX="CELT"
CeltConfPresent="false"
Sessions=(Notes Info Nano Vim Links)
SessionsCMDs=(./CELT.sh\ --help echo echo echo links)

read -d '' HelpMessage << EOF
CLI Environment Launcher for TMUX ($Name) v$Version
===================================================
This script can be leveraged as a simple script starter having basic features.
These features include the printing of a help message, license, printing of the
current version, and 'updating' of the shell from an online resource.
It's left to the developer to hodgepodge their code with this script.

Commands
--------
1. $0 Launches the tmux session ("$MainMUX") with configured windows
2. $0 killall (or restart): Kills ALL tmux sessions
3. $0 adduser (or useradd): Adds session with different name than "$defaultUser"
4. $0 connectas: Joins to "$MainMUX" as a specified user (see adduser above)
5. $0 list-all (or list): Shows the current windows for "$MainMUX"
6. $0 list-sessions (or sessions): Simply runs 'tmux ls'

Other Options
-------------
--license - print license
--version - print version number
--install - copy this script to /bin/($Name)
--update  - update to the most recent GitHub commit
EOF

read -d '' License << EOF
Copyright (c) 2016 Brandon Froberg

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
EOF

#######################################
#Start ShellShell

OType_1=$1
if [[ "$OType_1" == "--license" ]];then
   echo ""
   echo "$License"
   exit
fi

if [[ "$OType_1" == "--install" ]];then
   echo ""
   echo "Attempting to install $0 to /bin"

   User=`whoami`
   if [[ "$User" != "root" ]]; then
      echo "[WARNING] Currently NOT root!"
   fi
   cp $0 /bin/$Name
   Check=`ls /bin/$Name | wc -l`
   if [[ "$Check" == "1" ]]; then
      echo "$Name installed successfully!"
   fi
   exit
fi

if [[ "$OType_1" == "--help" ]] || [[ "$OType_1" == "-h" ]];then
   echo ""
   echo "$HelpMessage"
   exit
fi

if [[ "$OType_1" == "--version" ]];then
   echo ""
   echo "Version: $Version"
   echo "md5 (less last line): "`cat $0 | grep -v "###" | md5sum | awk '{print $1}'`
   exit
fi

if [[ "$1" == "--check-script" ]] || [[ "$1" == "--crc" ]];then
   CRCRan=`$0 --version | grep "md5" | tr ":" "\n" | grep -v "md5" | tr -d " "`
   CRCScript=`tail -1 $0 | grep -v "md5sum" | grep -v "cat" | tr ":" "\n" | grep -v "md5" | tr -d " " | grep -v "#"`

   if [[ "$CRCRan" == "$CRCScript" ]]; then
      echo "$0 is good!"
   else
      echo "The checksums didn't match!"
      echo "1. $CRCRan  (vs.)"
      echo "2. $CRCScript"
   fi
   exit
fi

if [[ "$1" == "--update" ]];then
   echo ""
   if [[ "`which wget`" != "" ]]; then
      echo "Grabbing latest GitHub commit..."
      wget $url -O /tmp/junk$Name
   elif [[ "`which curl`" != "" ]]; then
      echo "Grabbing latest GitHub commit...with curl...ew"
      curl $url > /tmp/junk$Name
   else
      echo "... or I cant; Install wget or curl"
   fi

   if [[ -f /tmp/junk$Name ]]; then
      lastVers="$Version"
      newVers=`cat /tmp/junk$Name | grep "Version=" | grep -v "cat" | tr "\"" "\n" | grep "\."`

      lastVersHack=`echo "$lastVers" | tr "." " " | awk '{printf("9%04d%04d%04d",$1,$2,$3)}'`
      newVersHack=`echo "$newVers" | tr "." " " | awk '{printf("9%04d%04d%04d",$1,$2,$3)}'`

      echo ""
      if [[ "$lastVersHack" -lt "$newVersHack" ]]; then
         echo "Updating $Name to $newVers"
         chmod +x /tmp/junk$Name

         echo "Checking the CRC..."
         CheckCRC=`/tmp/junk$Name --check-script | grep "good" | wc -l`

         if [[ "$CheckCRC" == "1" ]]; then
            echo "Installing ..."
            /tmp/junk$Name --install
         else
            echo "ERROR! The CRC failed, considering file to be bad!"
            rm /tmp/junk$Name
            exit
         fi
         rm /tmp/junk$Name
      else
         echo "You are up to date! ($lastVers)"
      fi
   else
      echo "Well ... that happened. (Check your Inet; the new $Name couldn't be grabbed!"
   fi
   exit
fi

#######################################
#Start CELT

echo ""
echo "$Name v$Version"
echo "============="

if [[ "$1" == "restart" ]] || [[ "$1" == "killall" ]]; then
   echo "Killing all TMUX sessions..."
   Sessions=`tmux ls | awk '{print $1}' | tr -d ":"`
   for i in $Sessions; do
      tmux kill-session -t $i
   done
   Running=`tmux ls | wc -l 2>/dev/null`
   if [[ "$Running" == "0" ]];then
      echo "Success!"
   else
      echo "[ERROR] Could NOT stop sessions. Current sessions: "
      tmux ls
   fi

elif [[ "$1" == "adduser" ]] || [[ "$1" == "useradd" ]]; then
   UserName="$2"
   echo "Attempting to create New Session (named $UserName) attached to $MainMUX"
   FindName=`tmux ls | grep $UserName`
   if [[ "$FindName" == "" ]]; then
      tmux new -s $UserName -t $MainMUX -d
   else
      echo "[ERROR] User session (named $UserName) is already created!"
      echo "[ERROR] Run: '$0 connectas $UserName' to connect!"
   fi

elif [[ "$1" == "connectas" ]]; then
   UserName="$2"
   echo "Attempting to join to session (named $UserName)"
   FindName=`tmux ls | grep $UserName`
   if [[ "$FindName" != "" ]]; then
      tmux a -t $UserName
   else
      echo "[ERROR] Cannot find User '$UserName'. Try running '$0 adduser $UserName'"
      tmux ls
   fi
elif [[ "$1" == "list" ]] || [[ "$1" == "list-all" ]]; then
   tmux list-windows -t $MainMUX
elif [[ "$1" == "sessions" ]] || [[ "$1" == "list-sessions" ]]; then
   tmux ls
elif [[ "$1" == "" ]]; then
   FindMUX=`tmux ls | grep $MainMUX`

   if [[ -f "./celt.conf" ]]; then
      CeltConfPresent="true"
      echo "Config file FOUND... loading!"
      CountSessions=`cat $CurrDir/celt.conf  | grep -v "#" | grep . | grep "CELT_Session" | grep "_Name" | wc -l`
      TotalSessions=${#Sessions}

      if [[ $TotalSessions -gt $CountSessions ]]; then
         echo "WARNING: Less Windows then default! Re-rolling the array..."
         Sessions=( First Second )
         SessionsCMDs=( echo echo )
      fi

      NewSessions=$(( CountSessions - 1 ))
      #for i in `seq 1 $CountSessions`; do
      for i in `seq 0 $NewSessions`; do
         CurrSession=`cat $CurrDir/celt.conf | grep "CELT_Session"$i"_Name" | tr "=" "\n" | grep -v "CELT_Session" | grep . | tr -d "\""`
         echo "Adding new Sessions[$i]: $CurrSession"
         CurrCMD=`cat $CurrDir/celt.conf | grep "CELT_Session"$i"_CMD" | tr "=" "\n" | grep -v "CELT_Session" | grep . | tr -d "\""`
         echo "Adding new SessionsCMDs[$i]: $CurrCMD"
         Sessions[$i]="$CurrSession"
         SessionsCMDs[$i]="$CurrCMD"
      done
   else
      echo "No Config file... Loading the default settings!"
   fi

   if [[ "$FindMUX" == "" ]]; then
      tmux new -s $MainMUX -d
      tmux rename-window -t $MainMUX:0 ${Sessions[0]}
      tmux send -t $MainMUX:0 "${SessionsCMDs[0]}" ENTER
      tmux neww -t $MainMUX -n ${Sessions[1]}
      tmux send -t $MainMUX:1 "${SessionsCMDs[1]}" ENTER
      tmux neww -t $MainMUX -n ${Sessions[2]}
      tmux send -t $MainMUX:2 "${SessionsCMDs[2]}" ENTER
      tmux neww -t $MainMUX -n ${Sessions[3]}
      tmux send -t $MainMUX:3 "${SessionsCMDs[3]}" ENTER
      tmux neww -t $MainMUX -n ${Sessions[4]}
      tmux send -t $MainMUX:4 "${SessionsCMDs[4]}" ENTER

      #Tmux Settings
         tmux set -g history-limit 10000
         #set color for status bar
         tmux set-option -g status-bg colour235 #base02
         tmux set-option -g status-fg green
         tmux set-option -g status-attr bright
         tmux set -g status-right-length 50
         tmux set -g status-left-length 30


         #set window list colors - red for active and cyan for inactive
         tmux set-window-option -g window-status-fg brightblue #base0
         tmux set-window-option -g window-status-bg colour236
         tmux set-window-option -g window-status-attr dim

         tmux set-window-option -g window-status-current-bg colour235
         tmux set-window-option -g window-status-current-fg yellow #orange
         tmux set-window-option -g window-status-current-attr bright
         tmux set-option -g allow-rename off
         tmux bind -n M-Left select-pane -L
         tmux bind -n M-Right select-pane -R
         tmux bind -n M-Up select-pane -U
         tmux bind -n M-Down select-pane -D
         tmux set -g mouse on

      echo "DONE! Created the tmux session $MainMUX with windows:"
      tmux list-windows -t $MainMUX
      echo "Attempting to add user session: '$defaultUser'..."
      $0 useradd $defaultUser
      echo "Attempting to connect as: '$defaultUser'"
   else
      echo "[CELT] It appears the Session $MainMUX is already running: "
      echo ""
      tmux ls
      echo ""
   fi
   $0 connectas $defaultUser
else
   echo "[ERROR] Unknown Command \"$1\""
   echo ""
   echo "$HELP"
fi

echo ""

### Current File MD5 (less this line): 3e5cdada78abaa1f7a724e0b82f725ba
