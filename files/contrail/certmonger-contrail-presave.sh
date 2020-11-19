#!/bin/bash -x

container_cli=$(sudo hiera -c /etc/puppet/hiera.yaml container_cli docker)
containers=$(sudo $container_cli ps --format="{{.Names}}" | grep contrail)
if [[ -n "$containers" ]] ; then
  sudo $container_cli stop $containers
fi
# fix selinux perms as old containers do mount w/o ro
# and type is changed to container_file_t as containers are started
sudo chcon -R -t cert_t /etc/contrail/ssl || true
