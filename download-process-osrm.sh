#!/bin/bash

#set up log output
#!/bin/bash
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/osm/log.out 2>&1
# Everything below will go to the file 'log.out':

echo "$(date) : ---------------- start ----------------" >&3
echo "$(date) : ---------------- start ----------------"
cd /osm || exit $?

#set cwd
echo "$(date) : set cwd to /osm" >&3
echo "$(date) : set cwd to /osm"
cd /osm || exit $?

# download
if [[ "$1" == "'-d'"]]; then
	echo "$(date) : downloading from geofabrik" >&3
	echo "$(date) : downloading from geofabrik"
	wget http://download.geofabrik.de/north-america-latest.osm.pbf || exit $?
	mv north-america-latest.osm.pbf north-america.osm.pbf
fi

#set cwd
cd /osm/osrm

#extract
echo "$(date) : osrm-extract" >&3
echo "$(date) : osrm-extract"
./osrm-extract /osm/north-america.osm.pbf || exit $?

#prepare
echo "$(date) : osrm-prepare" >&3
echo "$(date) : osrm-prepare"
./osrm-prepare /osm/north-america.osrm /osm/north-america.osrm.restrictions || exit $?

echo "$(date) : ---------------- end, halting ----------------" >&3
echo "$(date) : ---------------- end, halting ----------------"
cd /osm || exit $?

#and terminate the instance
sudo halt
