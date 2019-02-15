#!/bin/sh
WORKING_DIRECTORY="$PWD"

echo "Changing directory to $BASTILLION_HOME"

cd $BASTILLION_HOME

PARAM="$1"
if [[ "$PARAM" == '-b' || "$PARAM" == '-background' ]]; then
  mvn package jetty:run &
  echo "Server started @ IP 8443 unless changed in config file"
  echo "Returning to $WORKING_DIRECTORY"
  cd $WORKING_DIRECTORY
else
  mvn package jetty:run
fi
