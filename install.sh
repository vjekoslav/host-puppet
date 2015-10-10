#!/bin/sh
if [ "$(id -u)" != "0" ]; then
   echo "Sorry, you are not root."
   exit 1
fi

echo "Installing puppet agent and gem for librarian-puppet"
# enable repo for 14.04
wget --quiet https://apt.puppetlabs.com/puppetlabs-release-trusty.deb -P /tmp/

dpkg -i /tmp/puppetlabs-release-trusty.deb
apt-get -qq update

apt-get -qq install puppet rubygems-integration

echo "Installing librarian puppet and installing puppet dependencies"
# install gem and librarian-puppet
gem install librarian-puppet

# install dependecies 
librarian-puppet install

echo "Applying manifests"
puppet apply manifests/init.pp --modulepath=modules
