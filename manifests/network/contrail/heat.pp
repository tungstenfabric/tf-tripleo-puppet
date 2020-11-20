#
# Copyright (C) 2015 Juniper Networks
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: tripleo::network::contrail::heat
#
# Configure Contrail Heat plugin
#
# == Parameters:
#
# [*admin_password*]
#  (optional) admin password
#  String value.
#  Defaults to hiera('contrail::admin_password')
#
# [*admin_tenant_name*]
#  (optional) admin tenant name.
#  String value.
#  Defaults to hiera('contrail::admin_tenant_name')
#
# [*admin_user*]
#  (optional) admin user name.
#  String value.
#  Defaults to hiera('contrail::admin_user')
#
# [*api_server*]
#  (optional) IP address of api server
#  String value.
#  Defaults to hiera('contrail_config_vip',hiera('internal_api_virtual_ip'))
#
# [*api_port*]
#  (optional) port of api server
#  String value.
#  Defaults to hiera('contrail::api_port')
#
# [*auth_host*]
#  (optional) keystone server ip address
#  String (IPv4) value.
#  Defaults to hiera('contrail::auth_host')
#
# [*step*]
#  (optional) Step stack is in
#  Integer value.
#  Defaults to hiera('step')
#
# [*contrail_api_ssl_enabled*]
#  (optional) switch for ssl usage
#  String value.
#  Defaults to 'False'
#
# [*contrail_heat_extra_config*]
#  (optional) A hash which contain additional configuration for heat.conf
#  Example:
#    {'SECTION' => {
#       key => value
#      }
#    }
#  Defaults to empty hash.

class tripleo::network::contrail::heat(
  $step                              = Integer(hiera('step')),
  $auth_host                         = hiera('contrail::auth_host'),
  $auth_protocol                     = hiera('contrail::auth_protocol'),
  $admin_password                    = hiera('contrail::admin_password'),
  $admin_user                        = hiera('contrail::admin_user'),
  $admin_tenant_name                 = hiera('contrail::admin_tenant_name'),
  $api_server                        = hiera('contrail_config_ips', hiera('contrail_config_vip', hiera('internal_api_virtual_ip'))),
  $api_port                          = hiera('contrail::api_port', '8082'),
  $api_server_use_ssl                = hiera('contrail_internal_api_ssl', false),
  $heat_config_extra                 = hiera('contrail_heat_config_extra', {}),
) {

  # heat is executed at $step >= 3
  if $step >= 3 {

    if $api_server_use_ssl {
      $use_ssl = 'True'
    } else {
      $use_ssl = 'False'
    }

    $contrail_config = {
      'clients_contrail' => {
        'api_base_url'  => '/',
        'api_server'    => regsubst($api_server, ',', ' ', 'G'),
        'api_port'      => $api_port,
        'auth_host_ip'  => $auth_host,
        'auth_protocol' => $auth_protocol,
        'user'          => $admin_user,
        'password'      => $admin_password,
        'tenant'        => $admin_tenant_name,
        'use_ssl'       => $use_ssl,
      },
    }

    $heat_config = deep_merge($heat_config_extra, $contrail_config)

    validate_hash($heat_config)
    $contrail_heat_config = { 'path' => '/etc/heat/heat.conf' }
    create_ini_settings($heat_config, $contrail_heat_config)
  }
}
