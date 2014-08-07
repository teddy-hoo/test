#!bin/env/bash

#Import the public key used by the package management system
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10

#Create a list file for MongoDB
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list

#Reload local package database
sudo apt-get update

#Install the MongoDB packages
sudo apt-get install mongodb-org
