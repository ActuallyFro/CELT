#!/bin/bash
MainMUX="C2MUX"
Session0="Notes"
Session1="InfoGathering"
Session2="Enumeration"
Session3="Exploit"
Session4="Access"
Session5="Persistence"

Version="1.0.0"

read -r -d '' HELP <<HELPMSG
Commands
--------
$0:
This will simply attempt to launch the tmux session ("$MainMUX") with the default windows

$0 killall (or restart):
These commands will kill ALL tmux sessions.

$0 adduser (or useradd):
This creates a session attached to "$MaminMUX", which will allow a user to join via the
command 'connectas'.

$0 connectas:
Joins to "$MainMUX" as a specified user.

$0 list-all (or list):
Shows the current windows for "$MainMUX"

$0 list-sessions (or sessions):
Simply runs 'tmux ls'


HELPMSG

echo ""
echo "TMUX Launcher"
echo "============="
if [[ "$1" == "--help" ]] || [[ "$1" == "--version" ]] || [[ "$1" == "-v" ]] || [[ "$1" == "-h" ]];then
   echo ""
   echo "Version $Version"
   echo ""
   echo "This tool is designed to launch a Pentesting Tmux Command and Control Session with a default set of"
   echo "windows. Ideally these windows are setup to allow a team to compartmentalize work for a better red"
   echo "team experience."
   echo ""
   echo "$HELP"
   echo -e "\t\t\t\t- ActuallyFro -- 2016"
elif [[ "$1" == "restart" ]] || [[ "$1" == "killall" ]]; then
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
   if [[ "$FindMUX" == "" ]]; then
      tmux new -s $MainMUX -d
      tmux rename-window -t $MainMUX:0 $Session0
      tmux neww -t $MainMUX -n $Session1
      tmux neww -t $MainMUX -n $Session2
      tmux neww -t $MainMUX -n $Session3
      tmux neww -t $MainMUX -n $Session4
      tmux neww -t $MainMUX -n $Session5

      #Tmux Settings
         tmux set -g history-limit 10000
         #set color for status bar
         tmux set-option -g status-bg colour235 #base02
         tmux set-option -g status-fg green
         tmux set-option -g status-attr bright

         #set window list colors - red for active and cyan for inactive
         tmux set-window-option -g window-status-fg brightblue #base0
         tmux set-window-option -g window-status-bg colour236
         tmux set-window-option -g window-status-attr dim

         tmux set-window-option -g window-status-current-bg colour235
         tmux set-window-option -g window-status-current-fg yellow #orange
         tmux set-window-option -g window-status-current-attr bright

      echo "DONE! Created the tmux session $MainMUX with windows:"
      tmux list-windows -t $MainMUX
   else
      echo "[ERROR] It appears the Session $MainMUX is already running: "
      echo ""
      tmux ls
      echo ""
      echo ""
      echo "[ERROR] Run '$0 killall' to destroy all running tmux sessions"
   fi
else
   echo "[ERROR] Unknown Command \"$1\""
   echo ""
   echo "$HELP"
fi

echo ""


#Copyright (c) 2016 Brandon Froberg
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
#associated documentation files (the "Software"), to deal in the Software without restriction,
#including without limitation the rights to use, copy, modify, merge, publish, distribute,
#sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies or
#substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
#BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
#DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
