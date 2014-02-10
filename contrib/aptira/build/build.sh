export HTTP_MIRROR=mirror.aarnet.edu.au
export HTTP_PROXY=192.168.0.13:8000

# debootstrap is almost entirely wget, and will ignore the
# host system's proxy settings.
echo "http_proxy = $HTTP_PROXY" >> /etc/wgetrc

apt-get update
apt-get install python-dev python-pip git -y

pip install ansible

# something weird going on here
service xinetd restart

# build a minimal debian to boot from
cd /var/lib/edeploy/build
make REPOSITORY=http://$HTTP_MIRROR/ubuntu DIST=precise

# copy initrd and kernel of minimal debian to tftp dir
cp /var/lib/debootstrap/install/D7-H.1.0.0/base/boot/vmlinuz* /var/lib/tftpboot/vmlinuz
cp /var/lib/debootstrap/install/D7-H.1.0.0/initrd.pxe /var/lib/tftpboot
chown -R tftp:tftp /var/lib/tftpboot
chmod a+r /var/lib/tftpboot/vmlinuz

# Cloud role, containing cloud-init
wget https://raw2.github.com/enovance/edeploy-roles/master/cloud.install
wget https://raw2.github.com/enovance/edeploy-roles/master/cloud.exclude
chmod a+x cloud.install

# Base openstack role, containing puppet and setting cloud archive
wget https://raw2.github.com/enovance/edeploy-roles/master/openstack-common.install
wget https://raw2.github.com/enovance/edeploy-roles/master/openstack-common.exclude
chmod a+x openstack-common.install

# Base openstack role, containing puppet and setting cloud archive
wget https://raw2.github.com/enovance/edeploy-roles/master/openstack-full.install
wget https://raw2.github.com/enovance/edeploy-roles/master/openstack-full.exclude
chmod a+x openstack-full.install

# Make the root password 'test' for openstack-common nodes
echo "do_chroot \${dir} usermod --password p1fhTXKKhbc0M root" >> openstack-common.install

# Create build rules for cloud and openstack-common
cat >> /var/lib/edeploy/build/Makefile <<EOF
cloud: \$(INST)/cloud.done
\$(INST)/cloud.done: cloud.install \$(INST)/base.done
	./cloud.install \$(INST)/base \$(INST)/cloud \$(VERS)
	touch \$(INST)/cloud.done

openstack-common: \$(INST)/openstack-common.done
\$(INST)/openstack-common.done: openstack-common.install \$(INST)/cloud.done
	./openstack-common.install \$(INST)/cloud \$(INST)/openstack-common \$(VERS)
	touch \$(INST)/openstack-common.done

openstack-full: $(INST)/openstack-full.done
$(INST)/openstack-full.done: openstack-full.install $(INST)/openstack-common.done
    ./openstack-full.install $(INST)/openstack-common $(INST)/openstack-full $(VERS)
    touch $(INST)/openstack-full.done
EOF

# build the openstack-common role for debian wheezy and increment version
make DIST=precise VERSION='H.1.0.1' REPOSITORY=http://$HTTP_MIRROR/ubuntu openstack-full

# Now we build a hardware profile, called control-server
# This will run the control plane services.
cat > /var/lib/edeploy/config/control-server.configure <<EOF
# -*- python -*-

bootable_disk = '/dev/' + var['disk']

run('dmsetup remove_all || /bin/true')

for disk, path in ((bootable_disk, '/chroot'), ):
    run('parted -s %s mklabel msdos' % disk)
    run('parted -s %s mkpart primary ext2 0%% 100%%' % disk)
    run('dmsetup remove_all || /bin/true')
    run('mkfs.ext4 %s1' % disk)
    run('mkdir -p %s; mount %s1 %s' % (path, disk, path))

open('/post_rsync/etc/network/interfaces', 'w').write('''
auto lo
iface lo inet loopback

auto %(eth)s
allow-hotplug %(eth)s
iface %(eth)s inet static
  address %(ip)s
  netmask %(netmask)s
''' % var)

open('/post_rsync/etc/hostname','w').write('''
%(hostname)s
''' % var)

open('/post_rsync/etc/hosts','w').write('''
127.0.0.1   localhost
127.0.1.1 %(hostname)s.%(domain)s %(hostname)
# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost   ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
%(ip)s %(hostname)s  %(hostname)s.%(domain)s
192.168.242.100 build-server build-server.%(domain)s
''' % var)

set_role('openstack-full', 'D7-H.1.0.1', bootable_disk)
EOF

# This profile will be used to run compute services
cat > /var/lib/edeploy/config/compute-server.configure <<EOF
# -*- python -*-

bootable_disk = '/dev/' + var['disk']

run('dmsetup remove_all || /bin/true')

for disk, path in ((bootable_disk, '/chroot'), ):
    run('parted -s %s mklabel msdos' % disk)
    run('parted -s %s mkpart primary ext2 0%% 100%%' % disk)
    run('dmsetup remove_all || /bin/true')
    run('mkfs.ext4 %s1' % disk)
    run('mkdir -p %s; mount %s1 %s' % (path, disk, path))

open('/post_rsync/etc/network/interfaces', 'w').write('''
auto lo
iface lo inet loopback

auto %(eth)s
allow-hotplug %(eth)s
iface %(eth)s inet static
  address %(ip)s
  netmask %(netmask)s
''' % var)

open('/post_rsync/etc/hostname','w').write('''
%(hostname)s
''' % var)

open('/post_rsync/etc/hosts','w').write('''
127.0.0.1   localhost
127.0.1.1 %(hostname)s.%(domain)s %(hostname)
# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost   ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
%(ip)s %(hostname)s  %(hostname)s.%(domain)s
192.168.242.100 build-server build-server.%(domain)s
''' % var)

set_role('openstack-full', 'D7-H.1.0.1', bootable_disk)
EOF

# Set it to match this type of physical hardware:
cat > /var/lib/edeploy/config/control-server.specs <<EOF
# -*- python -*-
[
    ('disk', '\$disk', 'size', 'gt(4)'),
    ('network', '\$eth', 'ipv4', 'network(192.168.242.0/24)')
]
EOF

cat > /var/lib/edeploy/config/compute-server.specs <<EOF
# -*- python -*-
[
    ('disk', '\$disk', 'size', 'gt(4)'),
    ('network', '\$eth', 'ipv4', 'network(192.168.242.0/24)')
]
EOF

# Generate a new IP in the non-dhcp range for our server
# This gets passed to the configure script, along with
# a hostname that will need to match a data model role
cat > /var/lib/edeploy/config/control-server.cmdb <<EOF
generate({'ip': '192.168.242.150-200',
          'netmask': '255.255.255.0',
          'hostname': 'control0-9',
          'domain': 'domain.name'
          })
EOF

cat > /var/lib/edeploy/config/compute-server.cmdb <<EOF
generate({'ip': '192.168.242.150-200',
          'netmask': '255.255.255.0',
          'hostname': 'compute0-9',
          'domain': 'domain.name'
          })
EOF

# This controls how many of each profile can be deployed
cat > /var/lib/edeploy/config/state <<EOF
[('control-server', '1')]
[('compute-server', '5')]
EOF

# Needs to be read/writeable by the edeploy server
chown -R www-data:www-data /var/lib/edeploy/config

# Now we make a new version, 1.0.2, that has telnet and less installed
cat > /var/lib/edeploy/build/upgrade-from.d/openstack-full-H.1.0.1_D7-H.1.0.2.upgrade <<EOF
. common
install_packages \$dir less telnet
EOF
chmod ug+x /var/lib/edeploy/build/upgrade-from.d/openstack-full-H.1.0.1_D7-H.1.0.2.upgrade

# now we update our install script to match
#cat >> /var/lib/edeploy/build/openstack-common.install <<EOF
#install_packages \$dir less telnet
#EOF

# Now build the new version
./upgrade-from openstack-full D7-H.1.0.1 D7-H.1.0.2 /var/lib/debootstrap
