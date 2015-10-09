#!/bin/sh
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# enable repo for 14.04
wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb /tmp/
dpkg -i /tmp/puppetlabs-release-trusty.deb
apt-get update

# install puppet
apt-get install puppet

# install gem
apt-get install rubygems-integration

gem install librarian-puppet