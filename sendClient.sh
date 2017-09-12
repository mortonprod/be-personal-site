#!/usr/bin/env bash


#First download the backend portfolio website github directory
#Then you should push your client build files from local to your new remote github clone.

#Then you should run the docker compose file


scp -r ./client/build root@178.62.101.238:/root/nginx-certbot/portFolioNodeBackend/client/
scp -r ./client/documentation root@178.62.101.238:/root/nginx-certbot/portFolioNodeBackend/client/
scp -r ./keys root@178.62.101.238:/root/nginx-certbot/portFolioNodeBackend/
scp -r ./robot.txt root@178.62.101.238:/root/nginx-certbot/portFolioNodeBackend/client/
scp -r ./sitemap.xml root@178.62.101.238:/root/nginx-certbot/portFolioNodeBackend/client/
