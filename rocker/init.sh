#!/bin/bash

#chmod u+x init.sh
#need to run as . init.sh (no ./ as we want to export env variables) (or source init.sh)

# First two lines are needed to ensure docker has permission to write to host drive
echo USERID:$(id -u) > .env
echo GROUPID:$(id -g) >> .env

# Second two lines need changing to reflect the location of the host folders that are to be used
export DATAHOME="$HOME"
export TEMP_R_LIBRARY="$HOME/rocker_packages"
