#!/bin/bash
cd "$(dirname "$0")"
java -Xms128m -Xmx16384m -jar StarMade.jar -server
