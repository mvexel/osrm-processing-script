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

#update osm data
echo "$(date) : update planet file" >&3
echo "$(date) : update planet file"
/osm/osmupdate /osm/north-america.osm.pbf /osm/north-america-new.osm.pbf -B=/osm/north-america.poly || exit $?

#overwrite old osm file
echo "$(date) : replace old planet file" >&3
echo "$(date) : replace old planet file"
mv /osm/north-america-new.osm.pbf /osm/north-america.osm.pbf || exit $?

#convert to pbf
#echo "$(date) : generate pbf file" >&3
#echo "$(date) : generate pbf file"
#/osm/osmconvert /osm/north-america.o5m -o=/osm/north-america.osm.pbf || exit $?

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
