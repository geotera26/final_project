#! /bin/bash

# The purpose of this script is to reorganize the lon/lat/labels
# of MochaMarineVersion2, which is not usable as currently given
# for GMT

# Substitute comma for white space and save as MOCHA_sitelab.txt
cat MochaMarineVersion2.txt | sed 's/,/ /g' > MOCHA_sitelab.txt
