#!/bin/bash -x

container_cli=$(sudo hiera -c /etc/puppet/hiera.yaml container_cli docker)
containers=$(sudo $container_cli ps -a --format="{{.Names}}" | grep -v init | grep contrail)
if [[ -n "$containers" ]] ; then
  sudo $container_cli restart $containers
else
  echo "WARN: no contrail containers to start"
fi
