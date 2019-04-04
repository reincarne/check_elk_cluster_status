#!/usr/bin/python

# Author: Alex Ledovski
# Date: 20.02.19
# Description: This script takes the URl and sends an GET request to the ELK link. The URL is the cluster which sends back
# a JSON response. What we are looking for is the status - green/red/yellow and trigger an alert accordingly.

import requests
import json
import urllib3
import sys
from argparse import ArgumentParser

# Avoid SSL related warning messages
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
urllib3.disable_warnings(urllib3.exceptions.InsecurePlatformWarning)
urllib3.disable_warnings(urllib3.exceptions.SNIMissingWarning)

####  Arguments  #####
parser = ArgumentParser()
parser.add_argument("-u", "--url", dest="url" , type=str , required=True , help="ELK URL server name. Example: elk-mobile.net") #argument that gets the influxdb ELB
args = parser.parse_args()


elk_url=args.url

fullURL = "https://"+elk_url+":9200/_cluster/health?pretty"

username="USER_HERE"
password="PASSWORD_HERE"

try:
        response = requests.get(fullURL, verify=False,  auth=(username, password), headers={"Content-Type":"application/json"});
        res = json.loads(response.text)
except Exception as e:
    print ("UNKNOWN! issue when sending the request.")
    print (e)
    sys.exit(3)

clusterName = res['cluster_name']
clusterStatus = res['status']

if (clusterStatus == "green"):
        print "OK - the cluster " + clusterName + " is up. Cluster status is: " + clusterStatus
        sys.exit(0)
elif (clusterStatus == "yellow"):
        print "WARNING - one of the nodes in cluster " + clusterName + " is down. Cluster status is: " + clusterStatus
        sys.exit(1)
else:
        print "CRITICAL - the cluster " + clusterName + " is down. Cluster status is: " + clusterStatus
        sys.exit(2)

