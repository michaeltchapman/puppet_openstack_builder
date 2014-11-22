# To make a custom distribution, fork each of these repos and
# export reposource=<your github organisation>.
# The ref can also be specified using reporef for doing releases

git_protocol = ENV['git_protocol'] || 'https'
reposource   = ENV['reposource']   || 'upstream'
reporef   = ENV['reporef']   || 'upstream'
git_protocol = 'https'

if reposource != 'downstream'
  author = reposource
  ref = reporef
else
  ref = 'master'
end

# apache
if reposource != 'downstream'
  author = 'puppetlabs'
end
mod 'puppetlabs/apache', :git => "#{git_protocol}://github.com/#{author}/puppetlabs-apache.git", :ref => ref

# apt
if reposource != 'downstream'
  author = 'puppetlabs'
end
mod 'puppetlabs/apt', :git => "#{git_protocol}://github.com/#{author}/puppetlabs-apt.git", :ref => ref

# ceilometer
if reposource != 'downstream'
  author = 'stackforge'
end
mod 'stackforge/ceilometer', :git => "#{git_protocol}://github.com/#{author}/puppet-ceilometer.git", :ref => ref

# cinder
if reposource != 'downstream'
  author = 'stackforge'
end
mod 'stackforge/cinder', :git => "#{git_protocol}://github.com/#{author}/puppet-cinder.git", :ref => ref

# concat
if reposource != 'downstream'
  author = 'puppetlabs'
end
mod 'puppetlabs/concat', :git => "#{git_protocol}://github.com/#{author}/puppetlabs-concat.git", :ref => ref

# firewall
if reposource != 'downstream'
  author = 'puppetlabs'
end
mod 'puppetlabs/firewall', :git => "#{git_protocol}://github.com/#{author}/puppetlabs-firewall.git", :ref => ref

# galera
if reposource != 'downstream'
  author = 'michaeltchapman'
end
mod 'michaeltchapman/galera', :git => "#{git_protocol}://github.com/#{author}/puppet-galera.git", :ref => ref

# glance
if reposource != 'downstream'
  author = 'stackforge'
end
mod 'stackforge/glance', :git => "#{git_protocol}://github.com/#{author}/puppet-glance.git", :ref => ref

# haproxy
if reposource != 'downstream'
  author = 'puppetlabs'
end
mod 'puppetlabs/haproxy', :git => "#{git_protocol}://github.com/#{author}/puppetlabs-haproxy.git", :ref => ref

# heat
if reposource != 'downstream'
  author = 'stackforge'
end
mod 'stackforge/heat', :git => "#{git_protocol}://github.com/#{author}/puppet-heat.git", :ref => ref

# horizon
if reposource != 'downstream'
  author = 'stackforge'
end
mod 'stackforge/horizon', :git => "#{git_protocol}://github.com/#{author}/puppet-horizon.git", :ref => ref

# inifile
if reposource != 'downstream'
  author = 'puppetlabs'
end
mod 'puppetlabs/inifile', :git => "#{git_protocol}://github.com/#{author}/puppetlabs-inifile.git", :ref => ref

# keepalived
if reposource != 'downstream'
  author = 'arioch'
end
mod 'arioch/keepalived', :git => "#{git_protocol}://github.com/#{author}/puppet-keepalived.git", :ref => ref

# keystone
if reposource != 'downstream'
  author = 'stackforge'
end
mod 'stackforge/keystone', :git => "#{git_protocol}://github.com/#{author}/puppet-keystone.git", :ref => ref

# memcached
if reposource != 'downstream'
  author = 'saz'
end
mod 'saz/memcached', :git => "#{git_protocol}://github.com/#{author}/puppet-memcached.git", :ref => ref

# mysql
if reposource != 'downstream'
  author = 'puppetlabs'
end
mod 'puppetlabs/mysql', :git => "#{git_protocol}://github.com/#{author}/puppetlabs-mysql.git", :ref => ref

# neutron
if reposource != 'downstream'
  author = 'stackforge'
end
mod 'stackforge/neutron', :git => "#{git_protocol}://github.com/#{author}/puppet-neutron.git", :ref => ref

# nova
if reposource != 'downstream'
  author = 'stackforge'
end
mod 'stackforge/nova', :git => "#{git_protocol}://github.com/#{author}/puppet-nova.git", :ref => ref

# openstack
if reposource != 'downstream'
  author = 'stackforge'
end
mod 'stackforge/openstack', :git => "#{git_protocol}://github.com/#{author}/puppet-openstack.git", :ref => ref

# openstacklib
if reposource != 'downstream'
  author = 'stackforge'
end
mod 'stackforge/openstack_extras', :git => "#{git_protocol}://github.com/#{author}/puppet-openstack_extras.git", :ref => ref

# openstacklib
if reposource != 'downstream'
  author = 'stackforge'
end
mod 'stackforge/openstacklib', :git => "#{git_protocol}://github.com/#{author}/puppet-openstacklib.git", :ref => ref

# postgresql
if reposource != 'downstream'
  author = 'michaeltchapman'
end
mod 'puppetlabs/partial', :git => "#{git_protocol}://github.com/#{author}/puppet-partial.git", :ref => ref

# postgresql
if reposource != 'downstream'
  author = 'puppetlabs'
end
mod 'puppetlabs/postgresql', :git => "#{git_protocol}://github.com/#{author}/puppetlabs-postgresql.git", :ref => ref

# puppeels
if reposource != 'downstream'
  author = 'Mylezeem'
end
mod 'Mylezeem/puppeels', :git => "#{git_protocol}://github.com/#{author}/puppeels.git", :ref => ref

# puppet
if reposource != 'downstream'
  author = 'stephenrjohnson'
end
mod 'stephenrjohnson/puppet', :git => "#{git_protocol}://github.com/#{author}/puppetlabs-puppet.git", :ref => ref

# puppetdb
if reposource != 'downstream'
  author = 'puppetlabs'
end
mod 'puppetlabs/puppetdb', :git => "#{git_protocol}://github.com/#{author}/puppetlabs-puppetdb.git", :ref => ref

# rabbitmq
if reposource != 'downstream'
  author = 'puppetlabs'
end
mod 'puppetlabs/rabbitmq', :git => "#{git_protocol}://github.com/#{author}/puppetlabs-rabbitmq.git", :ref => ref

# rsync
if reposource != 'downstream'
  author = 'puppetlabs'
end
mod 'puppetlabs/rsync', :git => "#{git_protocol}://github.com/#{author}/puppetlabs-rsync.git", :ref => ref

# ruby-puppetdb
if reposource != 'downstream'
  author = 'ripienaar'
end
mod 'ripienaar/ruby-puppetdb', :git => "#{git_protocol}://github.com/#{author}/ruby-puppetdb.git", :ref => ref

# stacktira
if reposource != 'downstream'
  author = 'aptira'
end
mod 'aptira/stacktira', :git => "#{git_protocol}://github.com/#{author}/puppet-stacktira.git", :ref => ref

# staging
if reposource != 'downstream'
  author = 'nanliu'
end
mod 'nanliu/staging', :git => "#{git_protocol}://github.com/#{author}/puppet-staging.git", :ref => ref

# stdlib
if reposource != 'downstream'
  author = 'puppetlabs'
end
mod 'puppetlabs/stdlib', :git => "#{git_protocol}://github.com/#{author}/puppetlabs-stdlib.git", :ref => ref

# swift
if reposource != 'downstream'
  author = 'stackforge'
end
mod 'stackforge/swift', :git => "#{git_protocol}://github.com/#{author}/puppet-swift.git", :ref => ref

# sysctl
if reposource != 'downstream'
  author = 'thias'
end
mod 'thias/sysctl', :git => "#{git_protocol}://github.com/#{author}/puppet-sysctl.git", :ref => ref

# tempest
if reposource != 'downstream'
  author = 'stackforge'
end
mod 'stackforge/tempest', :git => "#{git_protocol}://github.com/#{author}/puppet-tempest.git", :ref => ref

# tftp
if reposource != 'downstream'
  author = 'puppetlabs'
end
mod 'puppetlabs/tftp', :git => "#{git_protocol}://github.com/#{author}/puppetlabs-tftp.git", :ref => ref

# vcsrepo
if reposource != 'downstream'
  author = 'puppetlabs'
end
mod 'puppetlabs/vcsrepo', :git => "#{git_protocol}://github.com/#{author}/puppetlabs-vcsrepo.git", :ref => ref

# vswitch
if reposource != 'downstream'
  author = 'stackforge'
end
mod 'stackforge/vswitch', :git => "#{git_protocol}://github.com/#{author}/puppet-vswitch.git", :ref => ref

# xinetd
if reposource != 'downstream'
  author = 'puppetlabs'
end
mod 'puppetlabs/xinetd', :git => "#{git_protocol}://github.com/#{author}/puppetlabs-xinetd.git", :ref => ref

