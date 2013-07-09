#!/usr/bin/env bash
# This bootstraps Puppet on CentOS 6.x
# It has been tested on CentOS 6.3 64bit

set -x

REPO_URL="http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-6.noarch.rpm"

if [ "$EUID" -ne "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

if which puppet > /dev/null 2>&1; then
  echo "Puppet is already installed."
else
  # Install puppet labs repo
  echo "Configuring PuppetLabs repo..."
  repo_path=$(mktemp)
  wget --output-document=${repo_path} ${REPO_URL} 2>/dev/null
  rpm -i ${repo_path} >/dev/null
  
  yum localinstall -y ${repo_path}
  
  # Install Puppet...
  echo "Installing puppet"
  yum install -y puppet > /dev/null
fi

echo "Enable pupetlabs Repo"
yum localinstall -y http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-6.noarch.rpm --nogpgcheck

echo "Enable Epel"
yum localinstall -y http://fedora.cu.be/epel/6/i386/epel-release-6-8.noarch.rpm --nogpgcheck

echo "Puppet installed!"
#set hostname
echo "127.0.0.1   puppet.example.com puppet" >> /etc/hosts
sysctl -w kernel.hostname=puppet

yum install git -y
master_bootstrap=$(mktemp)
rm -f $master_bootstrap
mkdir -p $master_bootstrap
cd $master_bootstrap

echo "get the necessary modules"
git clone https://github.com/theforeman/puppet-puppet.git puppet
git clone https://github.com/theforeman/puppet-git.git git
git clone https://github.com/theforeman/puppet-concat.git concat
git clone https://github.com/theforeman/puppet-passenger.git passenger
git clone https://github.com/theforeman/puppet-apache.git apache
git clone https://github.com/theforeman/puppet-foreman.git foreman
git clone https://github.com/theforeman/puppet-foreman.git
echo include puppet,puppet::server | puppet apply --debug --verbose --modulepath $master_bootstrap
