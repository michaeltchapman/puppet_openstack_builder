#!/usr/bin/env bash

# This script should:
#
# - Set a system wide package proxy if needed
# - Make sure ruby is installed
# - make sure puppet is installed
# - make sure a role has been set from somewhere:
#   - DNS
#   - hostname
#   - ???
# - make sure the fqdn is set and working
#
proxy="${proxy:-}"
desired_puppet=3.7.3

date

while getopts "h?p:" opt; do
    case "$opt" in
    h|\?)
        echo "Not helpful help message"
        exit 0
        ;;
    p)  proxy=$OPTARG
        ;;
    esac
done

# This might be a cloud instance. Grab config data if so.
# Try config drive first
if [ -e /dev/disk/by-label/config-2 ]; then
    if [ ! -d /mnt/config ]; then
      mkdir -p /mnt/config
      mount /dev/disk/by-label/config-2 /mnt/config
    fi
fi


for i in `ip -o link show | grep eth[1-9] | cut -d ':' -f 2`; do
    if [ -f /etc/sysconfig/network-scripts/ifcfg-eth0 ]; then
      cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-$i
      sed -i "s/eth0/$i/g" /etc/sysconfig/network-scripts/ifcfg-$i
    fi
    ethtool -K $i tso off
    ifconfig $i down
    ifconfig $i up
done

# not working yet
for i in `ip -o link show | grep enp[[:digit:]] | cut -d ':' -f 2`; do
    ethtool -K $i tso off
    ifconfig $i up
done

if ip -o link show | grep eth[1-9] ; then
  dhclient `ip -o link show | grep eth[1-9] | cut -d ':' -f 2 | tr '\n' ' '`
  dhclient eth0
fi

if ip -o link show | grep enp[[:digit:]]  ; then
  dhclient `ip -o link show | grep eth[1-9] | cut -d ':' -f 2 | tr '\n' ' '`
fi

# Set either yum or apt to use an http proxy.
if [ $proxy ] ; then
    echo 'setting proxy'
    export http_proxy=$proxy

    if [ -f /etc/redhat-release ] ; then
        if [ ! $(cat /etc/yum.conf | grep '^proxy=') ] ; then
            echo "proxy=$proxy" >> /etc/yum.conf
        fi
    elif [ -f /etc/debian_version ] ; then
        if [ ! -f /etc/apt/apt.conf.d/01apt-cacher-ng-proxy ] ; then
            echo "Acquire::http { Proxy \"$proxy\"; };" > /etc/apt/apt.conf.d/01apt-cacher-ng-proxy;
            apt-get update -q
        fi
    else
        echo "OS not detected! Weirdness inbound!"
    fi
else
    echo 'not setting proxy'
fi

hash puppet 2>/dev/null || {
      puppet_version=0
}

if [ "${puppet_version}" != '0' ] ; then
  puppet_version=$(puppet --version)
fi
if [ "${puppet_version}" != "${desired_puppet}" ] ; then
  echo '[puppetlabs]' > /etc/yum.repos.d/puppetlabs.repo
  echo "name=Puppetlabs Yum Repo" >> /etc/yum.repos.d/puppetlabs.repo
  echo "baseurl=\"http://yum.puppetlabs.com/el/\$releasever/products/\$basearch/\"" >> /etc/yum.repos.d/puppetlabs.repo
  echo 'enabled=1' >> /etc/yum.repos.d/puppetlabs.repo
  echo 'gpgcheck=1' >> /etc/yum.repos.d/puppetlabs.repo
  echo 'gpgkey=http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs' >> /etc/yum.repos.d/puppetlabs.repo

  echo '[puppetlabs-deps]' > /etc/yum.repos.d/puppetlabs-deps.repo
  echo "name=Puppetlabs Dependencies Yum Repo" >> /etc/yum.repos.d/puppetlabs-deps.repo
  echo "baseurl=\"http://yum.puppetlabs.com/el/\$releasever/dependencies/\$basearch/\"" >> /etc/yum.repos.d/puppetlabs-deps.repo
  echo 'enabled=1' >> /etc/yum.repos.d/puppetlabs-deps.repo
  echo 'gpgcheck=1' >> /etc/yum.repos.d/puppetlabs-deps.repo
  echo 'gpgkey=http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs' >> /etc/yum.repos.d/puppetlabs-deps.repo

  yum install puppet hiera -y -q
fi
date
yum install git -y -q
date
if [ ! -d /etc/puppet/hiera/data ]; then
    mkdir -p /etc/puppet/hiera/data
fi

configure_dir=/vagrant
cp $configure_dir/hiera/hiera.yaml /etc/puppet
cp $configure_dir/hiera/hiera.yaml /etc

rm -rf /etc/puppet/hiera/data
cp -r $configure_dir/hiera/data /etc/puppet/hiera

rm -rf /etc/puppet/manifests
cp -r $configure_dir/manifests /etc/puppet

# Convert puppet+hiera if cloud instance
if [ -e /dev/disk/by-label/config-2 ]; then
    python -c "import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin)['meta'], sys.stdout, default_flow_style=False)" < /mnt/config/openstack/latest/meta_data.json > /etc/puppet/hiera/data/cloudinit.yaml
fi

# Set role fact (mc - this should be from metadata)
mkdir -p /etc/facter/facts.d
echo "role: `hostname | grep -oh '^[[:alpha:]]*'`" > /etc/facter/facts.d/role.yaml

# Lock network facts to prevent bridge malarky
if ! [ -f /etc/facter/facts.d/ipaddress.yaml ]; then
  facter | grep ipaddress | sed 's/\ =>/:/' > /etc/facter/facts.d/ipaddress.yaml
fi
date

mkdir -p /vagrant/vendor
mkdir -p /vagrant/modules
# Use cloner (exp)
cd /vagrant
./provision/cloner repos.yaml
# Use librarian-puppet-simple
#export GEM_HOME=/vagrant/vendor
#if [ ! -f /vagrant/vendor/bin/librarian-puppet ]; then
#  gem install --no-ri --no-rdoc librarian-puppet-simple
#  date
#fi
#cd /vagrant
#vendor/bin/librarian-puppet install
date
# Install puppet modules
rm -rf /etc/puppet/modules
cp -r modules /etc/puppet/modules /etc/puppet

# Ensure puppet isn't going to sign a cert with the wrong time or
# name
domain=$(hiera domain)
ipaddress=$(facter mgmt_paddress)
fqdn=$(facter hostname).${domain}
facter_fqdn=$(facter fqdn)
# If it doesn't match what puppet will be setting for fqdn, just redo
# to the point where we can see the master and have fqdn
if [ "${facter_fqdn}" != "${fqdn}" ] ; then
  if ! grep -q "$ipaddress\s$fqdn" /etc/hosts ; then
    echo 'configuring /etc/hosts for fqdn'
    if [ -f /etc/redhat-release ] ; then
        echo "$ipaddress $fqdn $(hostname)" > /etc/hosts
        echo "127.0.0.1       localhost       localhost.localdomain localhost4 localhost4.localdomain4" >> /etc/hosts
        echo "::1     localhost       localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
        echo "$(hiera build_server_ip) $(hiera build_server_name) $(hiera build_server_name).$(hiera domain_name)" >> /etc/hosts
    elif [ -f /etc/debian_version ] ; then
        echo "$ipaddress $fqdn $(hostname)" > /etc/hosts
        echo "127.0.0.1       localhost       localhost.localdomain localhost4 localhost4.localdomain4" >> /etc/hosts
        echo "::1     localhost       localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
        echo "$(hiera build_server_ip) $(hiera build_server_name) $(hiera build_server_name).$(hiera domain_name)" >> /etc/hosts
    fi
  fi
fi

while true ; do
  puppet apply /etc/puppet/manifests/site.pp --detailed-exitcodes ;
  if (($? != 1 && $? != 4 && $? != 6)) ; then
    exit 0
  fi;
done;
