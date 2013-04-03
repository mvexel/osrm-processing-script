#!/bin/bash

#set up log output
#!/bin/bash
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/osm/log.out 2>&1
# Everything below will go to the file 'log.out':

dl=false
sus=false
filebasename="north-america"
upd=false

while getopts :db:suh opt
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
		h)
			echo "Usage:....read the source..." >&3
			exit 0
		;;
		\?)
			echo "Invalid option: -$OPTARG" >&3
			exit 1
		;;
	esac
done

filename="/osm/$filebasename.osm.pbf"
if [ -f $filename ]; then
	echo "Using input file $filename" >&3
	echo >&3
else
	echo "$filename does not exist." >&3
	exit 1
fi

updatefilename="/osm/$filebasename-new.osm.pbf"

echo "$(date) : ---------------- start ----------------" >&3
echo "$(date) : ---------------- start ----------------"
cd /osm || exit $?

#set cwd
echo "$(date) : set cwd to /osm" >&3
echo "$(date) : set cwd to /osm"
cd /osm || exit $?

# download - this is hardcoded for N-America and Geofabrik right now. 
if $dl ; then
	echo "$(date) : downloading from geofabrik" >&3
	echo "$(date) : downloading from geofabrik"
	wget http://download.geofabrik.de/north-america-latest.osm.pbf || exit $?
	mv north-america-latest.osm.pbf north-america.osm.pbf
fi

#update osm data
if $upd; then
	#set cwd
	cd /osm
	echo "$(date) : update planet file" >&3
	echo "$(date) : update planet file"
	/osm/osmupdate $filename $updatefilename || exit $?
	#overwrite old osm file
	echo "$(date) : replace old planet file" >&3
	echo "$(date) : replace old planet file"
	mv $updatefilename $filename || exit $?
fi

#set cwd
cd /osm/osrm

#extract
echo "$(date) : osrm-extract" >&3
echo "$(date) : osrm-extract"
./osrm-extract $filename || exit $?

#prepare
echo "$(date) : osrm-prepare" >&3
echo "$(date) : osrm-prepare"
./osrm-prepare /osm/$filebasename.osrm /osm/$filebasename.osrm.restrictions || exit $?

#finally create timestamp file:
/osm/osmconvert --out-statistics /osm/utah-latest.osm.pbf | sed -rne "s/timestamp max: (.+)/\1/p" > /osm/$filebasename.osrm.timestamp || exit $?

if $sus ; then
	echo "$(date) : ---------------- end, halting ----------------" >&3
	echo "$(date) : ---------------- end, halting ----------------"
	cd /osm || exit $?
	sudo halt || $?
else
	echo "$(date) : ---------------- end ----------------" >&3
	echo "$(date) : ---------------- end ----------------"
fi
