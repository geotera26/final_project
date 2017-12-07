#! /bin/bash

# The purpose of this script is to reorganize the lon/lat/labels
# of MochaMarineVersion2, which is not usable as currently given
# for GMT

cat MochaMarineVersion2.txt | awk '{print $1,$3}' > Mocha_stations.txt
cat MochaMarineVersion2.txt | sed 's/,/ /g' > file2 > MOCHA_sitelab.txt
