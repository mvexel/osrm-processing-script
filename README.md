osrm-processing-script
======================

Shell script to update local planet, prepare new OSRM data, and shut down EC2 instance

If you pass this as a user data script to ami-6045de09, it will update the local
N-America OpenStreetMap planet file, generate fresh OSRM data files off of it, 
and shut down again.
