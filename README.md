osrm-processing-script
======================

Shell script to automate OSRM data processing.

This script can perform any or all of:

* Download and/or update an OSM PBF file
* update and compile an existing OSRM installation
* Pre-process into OSRM data files
* Run OSRM server

The script is intended to be used on an Amazon EC2 instance based on ami-dc92f7b5 and is also included with that AMI. See the `example/launch-instance.sh` script and the accompanying `.userdata` file to get an idea of how to put this to work for you. You can also use it on a local machine, see below.

None of this comes with any warranty, expressed or implied. It works for me.

Quick Start - EC2 AMI
-----------
* Make sure you have the EC2 command line tools [installed and configured](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/setting_up_ec2_command_linux.html).
* Open `example/launch-instance.sh` in a text editor and tweak the instance settings.
* Open `example/process-osrm-na.userdata` in a text editor and tweak the OSRM processing execution parameters.
* Run `example/launch-instance.sh`.
* Your spot request info will be returned, use it to monitor launching of your instance yourself.
* After the instance launches, you can log in to it an monitor `/osm/log.out` for progress.

Quick Start - Local
-----------
You can set this up on a local machine as well. Everything is designed with Ubuntu Linux in mind, YMMV.
* clone this repository somewhere on your machine
* create directories `/osm` and `/osm/osrm`.
* in `/osm/osrm/`, clone OSRM like so: `git clone git://github.com/DennisOSRM/Project-OSRM.git .`.
* make sure you have all the OSRM prerequisites installed as described [here](https://github.com/DennisOSRM/Project-OSRM/wiki/Building-OSRM).
* go to your clone of this repo and try it out: `./download-process-osrm.sh -d http://download.geofabrik.de/north-america/us/utah-latest.osm.pbf -r`

After a few minutes, you should have a running OSRM installation with Utah data. Test it with: `http://localhost:5000/viaroute?loc=40.778230,-111.852230&loc=37.866638,-109.339371&instructions=true`.

Some things to keep in mind
---------------------------

* Don't just run the `download-process-osrm.sh` script locally. It won't do anything but throw a bunch of errors. It is tailored for a specific EC2 AMI.
* You will need at least an m2.4xlarge instance to process something the size of North America.
* The demo scripts request spot instances - they are cheap but there's no uptime guarantee. If the price goes up and you put in a conservative bid, you're screwed.
* The AMI is configured to retain the EBS volume storing the data after you destroy the instance, so you can attach the volume to another instance and use the processed data there. So remember to delete the EBS volume if you don't want it to avoid incurring EC2 fees for provisioned storage.
* Look at the example scripts to get an idea of how to make this work for you using the EC2 command line tools. 
* If you want to run the OSRM server from your instance, make sure that port 5000 is open in the EC2 security settings you use for your instance.

Copyright (c) 2013 Martijn van Exel

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

