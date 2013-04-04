#!/bin/sh

PRICE=".20"
SIZE="m2.4xlarge"
KEY="maproulette-test"
USERDATA="process-osrm-na.userdata"

if [ ! -f $USERDATA ]; then
    echo "$USERDATA does not exist, edit this script and provide"
    echo "the path to a valid user data file"
    exit 1
fi 

cat <<EOF

Going to request a $SIZE spot instance for bid price $PRICE.
We will use your key pair '$KEY'.
We will inject $USERDATA as a user data script, which 
by default will download a N-America planet from Geofabrik,
process it into OSRM binaries and run the OSRM server.

Have fun!

EOF

ec2-request-spot-instances ami-dc92f7b5 -p $PRICE -r $SIZE -k $KEY -f $USERDATA
