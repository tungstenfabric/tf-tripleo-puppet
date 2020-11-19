#!/bin/bash -x

# fix permisions as contrail services run udner contrail user / group
# but certmonger issues certs as root
cert=$(hiera -f json -c /etc/puppet/hiera.yaml contrail_certificates_specs | jq -c -r '.service_certificate')
key=$(hiera -f json -c /etc/puppet/hiera.yaml contrail_certificates_specs | jq -c -r '.service_key')
user=$(hiera -c /etc/puppet/hiera.yaml contrail::user root)
group=$(hiera -c /etc/puppet/hiera.yaml contrail::group 1999)
chmod 644 $cert
chmod 640 $key
chown $user:$group $cert $key

container_cli=$(sudo hiera -c /etc/puppet/hiera.yaml container_cli docker)
containers=$(sudo $container_cli ps -a --format="{{.Names}}" | grep -v init | grep contrail)
if [[ -n "$containers" ]] ; then
  sudo $container_cli restart $containers
else
  echo "WARN: no contrail containers to start"
fi
