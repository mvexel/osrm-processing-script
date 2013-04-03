#!/bin/bash

dl=false
sus=false
filebasename="north-america"
upd=false
runserver=false

while getopts :db:surh opt
do
	case "$opt" in
		d) 
			dl=true
		;;
		b)
			filebasename=$OPTARG
		;;
		s) 
			sus=true
		;;
		u)
			upd=true
		;;
		r)
			runserver=true
		;;
		h)
			cat <<EOF

Usage: `basename $0` [-dsurh] -b basename
  -b	Basename of PBF file (example: -b utah-latest will
	process /osm/utah-latest.osm.pbf
  -d	Download PBF first (hardcoded for N-America now,
	don't use in conjunction with -b)
  -s 	Suspend instance (halt) upon successful processing
  -u	Update PBF file to current state before processing
  -r	Run OSRM server upon successful processing
  -h	Display this help text

Examples:
  `basename $0`
	Will process an existing /osm/$filebasename.osm.pbf
	without updating into OSRM binaries.
  `basename $0` -b utah-latest -u -s
	Will process an existing /osm/utah-latest.osm.pbf,
	update it to current state, create OSRM binaries
	based off of this updated PBF file and halt this
	machine.

This script (c) 2013 Martijn van Exel. Released in the public
Domain. Be careful! I am horrible at this!

EOF
			exit 0
		;;
		:)
			echo "$OPTARG needs an argument."
			exit 1
		;;
		\?)
			echo "Invalid option: -$OPTARG"
			exit 1
		;;
	esac
done

filename="/osm/$filebasename.osm.pbf"
if [ -f $filename ]; then
	echo "Using input file $filename"
	echo
else
	echo "$filename does not exist."
	exit 1
fi

updatefilename="/osm/$filebasename-new.osm.pbf"

echo "$(date) : ---------------- start ----------------"
cd /osm || exit $?

#set cwd
echo "$(date) : set cwd to /osm"
cd /osm || exit $?

# download - this is hardcoded for N-America and Geofabrik right now. 
if $dl ; then
	echo "$(date) : downloading from geofabrik"
	wget http://download.geofabrik.de/north-america-latest.osm.pbf || exit $?
	mv north-america-latest.osm.pbf north-america.osm.pbf
fi

#update osm data
if $upd; then
	#set cwd
	cd /osm
	echo "$(date) : update planet file"
	/osm/osmupdate $filename $updatefilename || exit $?
	#overwrite old osm file
	echo "$(date) : replace old planet file"
	mv $updatefilename $filename || exit $?
fi

#set cwd
cd /osm/osrm

#extract
echo "$(date) : osrm-extract"
./osrm-extract $filename || exit $?

#prepare
echo "$(date) : osrm-prepare"
./osrm-prepare /osm/$filebasename.osrm /osm/$filebasename.osrm.restrictions || exit $?

#finally create timestamp file:
echo "$(date) : creating timestamp file"
/osm/osmconvert --out-statistics /osm/utah-latest.osm.pbf | sed -rne "s/timestamp max: (.+)/\1/p" > /osm/$filebasename.osrm.timestamp || exit $?

#create server.ini
echo "$(date) : creating server.ini file"
cat > /osm/osrm/server.ini <<EOF
Threads = 8
IP = 0.0.0.0
Port = 5000

hsgrData=/osm/$filebasename.osrm.hsgr
nodesData=/osm/$filebasename.osrm.nodes
edgesData=/osm/$filebasename.osrm.edges
ramIndex=/osm/$filebasename.osrm.ramIndex
fileIndex=/osm/$filebasename.osrm.fileIndex
namesData=/osm/$filebasename.osrm.names
timestamp=/osm/$filebasename.osrm.timestamp
EOF
 
if $sus ; then
	echo "$(date) : ---------------- end, halting ----------------"
	cd /osm || exit $?
	sudo halt || $?
elif $runserver ; then
	cd /osm/osrm || exit $?
	./osrm-routed &
	echo "$(date) : ---------------- end ----------------"
fi
