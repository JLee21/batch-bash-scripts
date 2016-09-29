#!/bin/bash

# VER1.3
# Added enchanced option that makes selecting the source and destination folder simpler.
#
# VER1.2 - 
# Trying to add dest and source variables so logs can be uploaded to other folder

# VER1.1 - 05.26.2015
# This version is so rough I don't know what to put here

# Variables
counter=0	#for counting the logs
maxDepthZip=4
minDepthZip=4
maxDepthRsync=4
minDepthRsync=4
sftext=/home/pf/scripts/sf.txt
dftext=/home/pf/scripts/df.txt
sfCounter=-1
dfCounter=-1
addTo=0
dontAdd=0

# color coordinators
bold="\e[1m"
red="\e[31;1m"
green="\e[32m"
yellow="\e[33m"
purple="\e[35m"
bluebg="\e[44m"
default="\e[0m"
dim="\e[2m"
blackbg="\e[40m"
redbg="\e[41m"
whitebg="\e[107m"
#echo -e "${red}${bold}${default}"
#echo -e "${blackbg}${bold}${default}"

# Find all the snapshots and show them to human to make sure they are the right ones
function showSnapshots () {
	clear
	echo 
	echo -e "${blackbg}${bold}Check if the following are the right snapshots...${default}"
	echo

	for file in `find $1 -mindepth $minDepthZip -maxdepth $maxDepthZip -amin -400 -type d ` ; #-name "[0-9]*"` ;
	do	
		((counter++)) #counter=$(($counter+1))
		fileName=$(cut -d "/" -f 7-11<<<$file)
		echo -e "${default}$counter----------${yellow}$fileName${default}"
	done
	#((counter++)) #add one to counter to avoid zero indexing
	counterMax=$counter #this holds the max number of snapshots to be handled
	echo
	echo -e "${red}Are the above snapshots the ones you want zipped and RSYNCed?"
	echo -e "Press a key to continue..."
	echo -e "${default}"
	read
	clear
}

#############################
# Zip
#############################
function zipped () {
	counter=0
	for file1 in `find $1 -mindepth $minDepthZip -maxdepth $maxDepthZip -amin -400 -type d ` ; #-name "[0-9]*"` ;
	do	
		fileName1=$(cut -d "/" -f 1-10<<<$file1)
		cd $fileName1
		#echo "file1 = $file1"
		#echo "fileName1 = $fileName1"
		fileName=$(awk -F'/' '{print $(NF-0)}' <<<$file1)
		truck=$(awk -F'/' '{print $(NF-1)}' <<<$file1)
		#echo "filename = $fileName and truck = $truck"
		#echo "$truck"_"$fileName.tgz"
		((counter++))
		echo -e "${default}$counter snapshot(s) zipped out of $counterMax${purple}"
		tar -zcvf $truck"_"$fileName.tgz $file1
		echo -e "${default}" 
	done
	echo "Finished Zip"
}

#############################
# RSYNC
#############################
function rsynced () {
	echo
	counter=0
	echo -e "${blackbg}${bold}RSYNC RSYNC!!${default}"
	for file2 in `find $1 -mindepth $minDepthRsync -maxdepth $maxDepthRsync -cmin -400 -iname "*.tgz"`;
	do	
		((counter++))
		#echo -e "${bold}$counter--${default}Snapshots Left to RSYNC${default}"
		echo -e "${default}$counter snapshot(s) RSYNCed out of $counterMax${purple}"
		echo -e "${green}" 
		rsync --progress -vhzc $file2 $2
		echo -e "${default}" 
		
	done
}
# S E N D   A L E R T   W H E N   D O N E ***************************************
figlet DONE

################################################################################
# Functions
################################################################################
function askUser () {
	echo -e "${blackbg}${bold}Select the Folder${default}"
	#determine if we're looking for the Source or Destination path
	if [ $1 == "s" ] ; then
		file='sf.txt'
		filePath=$sftext
	elif [ $1 == "d" ] ; then
		file='df.txt'
		filePath=$dftext
	else
		echo "bug in code"
	fi
	echo -e "Type the path to the Feature_Testing folder. ${dim}Ex /home/pf/log/" 
	echo
	read -p "Enter:" -e path
	# Check to see if the Folder already exists
	if [ -e $path ] || [ $path != " " ] ; then
	#echo "The answer you provided is valid"
	#read
		while read line
		do	
			((counter++))
				if [ "$line" != "First_Line" ] ; then
					if [ "$line" == "$path" ] ; then
						echo -e ${red}${bold}Hmmm...you just typed the path when it was already shown to you...try again${default}
						dontAdd=1
					else	
						echo -e "Setting flag to add new entry"
						addTo=1
					fi
				else
					echo -e "The  line value equals "First_Line" and there may be another entry"
				fi

		done < $file
		if [ $counter = 1 ] ; then
			echo "Adding to a blank text document"
			addTo=1
		fi

		if (($addTo == 1)) && (($dontAdd == 0)) ; then
			echo -e "Creating a new entry..."
			echo "$path" >> $filePath # $path should be an approved full path ex. /home/pf/log/		
		fi
		addTo=0
		dontAdd=0
		counter=0
		if [ $1 == "s" ] ; then
			getSourceFolder	
		fi
		getDestFolder		
		# Add the valid destination to sf.txt
	else
		((counter++))
		echo "${red}${bold}Your Path isn't valid. Enter again or mount the network drive${default}"
		if ( $counter == "s" ) ; then
			askUser "s"
		fi
		askUser "d"
	fi #is Source Folder path valid
}

function computeSourceOptions () {
	# if nothing was selected by user
	if [ $# -eq 0 ]; then
	    echo -e "${red}${bold}You Didn't Enter Anything ... Try Again${default}"
	    getSourceFolder 
	fi	

	if (( $1 < 0 )) ; then
		echo -e "${red}${bold}Input less than 0${default}"
	elif [ $1 = 0 ] ; then
		askUser	"s"	
	elif (( $1 > 0 )) && (( $1 <= $sfCounter )) ; then
		sf=${sourceFolder[$1]}
	elif (( $1 > $sfCounter )) ; then
		echo -e "${red}${bold}Input more than $sfCounter ${default}"
	fi
	echo "You have selected $sf aka ${sourceFolder[$1]}"
	echo "This ends the find-the-folder"
}
function computeDestOptions () {
	# if nothing was selected by user
	if [ $# -eq 0 ]; then
	    echo -e "${red}${bold}You Didn't Enter Anything ... Try Again${default}"
	    getDestFolder 
	fi	
	#echo "computeSourceOptions = $1"
	if (( $1 < 0 )) ; then
		echo -e "${red}${bold}Input less than 0${default}"
	elif [ $1 = 0 ] ; then
		askUser "d"	
	elif (( $1 > 0 )) && (( $1 <= $dfCounter )) ; then
		df=${destFolder[$1]}
		if [ ! -e $df ] ; then
			echo -e "${red}${bold}Error... the Destination folder does not exist...try mounting it if it's a drive${default}"
		fi
	elif (( $1 > $dfCounter )) ; then
		echo -e "${red}${bold}Input more than $dfCounter ${default}"
	fi
	echo "You have selected $df aka ${destFolder[$1]}"
	echo "This ends the find-the-folder"
}


#############################
# GET SOURCE FOLDER
#############################
function getSourceFolder () {
	clear
	sfCounter=-1
	# Look to see if sf.txt exists
	echo
	echo -e "${blackbg}${bold}Choose your Feature Folder ... ${default}"
	echo
	if [ -f $sftext ] ; then
		echo -e "0-- ${green}${bold}Type in Source Folder destination${default}"
		#pull the lines for sftext.txt and display them to user
		#sourceFolder[0] is the dummy line of the text file
		while read line
		do
			((sfCounter++))
			sourceFolder[$sfCounter]=$line
			if [ ! $sfCounter = 0 ] ; then
				echo -e "$sfCounter-- ${green}${bold}$line${default}"
			fi

		done < sf.txt
		echo
		read -p "Your Input: " sop

		echo
		computeSourceOptions $sop
	else 
		#have user type in the source folder
		#touch $sftext	
		echo "We have to creat the sf.txt"
		echo "First_Line" > $sftext	
		askUser "s"
	fi
}
#############################
# GET DEST FOLDER
#############################
function getDestFolder () {
	clear
	dfCounter=-1
	# Look to see if df.txt exists
	echo
	echo -e "${blackbg}${bold}Choose your Destination folder ... ${default}"
	echo
	if [ -f $dftext ] ; then
		echo -e "0-- ${green}${bold}Type in Source Folder destination${default}"
		#pull the lines for sftext.txt and display them to user
		#sourceFolder[0] is the dummy line of the text file
		while read line
		do
			((dfCounter++))
			destFolder[$dfCounter]=$line
			if [ ! $dfCounter = 0 ] ; then
				echo -e "$dfCounter-- ${green}${bold}$line${default}"
			fi
			# not sure if this loop reads blank lines
			#if [ $line = " " ] ; then
			#fi
		done < df.txt
		echo
		read -p "Your Input: " sop
		echo
		computeDestOptions $sop
	else #have user type in the source folder
		echo "We have to creat the df.txt"
		echo "First_Line" > $dftext	
		askUser "d"
	fi
}

#############################
# M A I N
#############################
# Verify that /media/ is "linked"
if grep -w '/media/' /etc/mtab > /dev/null 2>&1 ; then
	clear
else
	echo -e "${red}${bold}/media/ not mounted\n...Press enter after Mounting to go back to script${default}"
	source ~/scripts/Net_mount.sh
fi
getSourceFolder
getDestFolder
showSnapshots $sf
zipped $sf
rsynced $sf $df
figlet DONE  WITH  ZIP \'  RSYNC

