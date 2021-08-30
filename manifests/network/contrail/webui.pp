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
# == Class: tripleo::network::contrail::webui
#
# Configure Contrail Webui services
#
# == Parameters:
#
# [*step*]
#  The current step of the deployment
#  Defaults to hiera('step')
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
# [*admin_token*]
#  (optional) admin token
#  String value.
#  Defaults to hiera('contrail::admin_token')
#
# [*admin_user*]
#  (optional) admin user name.
#  String value.
#  Defaults to hiera('contrail::admin_user')
#
# [*auth_host*]
#  (optional) keystone server ip address
#  String (IPv4) value.
#  Defaults to hiera('contrail::auth_host')
#
# [*auth_port_internal*]
#  (optional) keystone port.
#  Integer value.
#  Defaults to hiera('contrail::auth_port_internal')
#
# [*cassandra_server_list*]
#  (optional) List IPs+port of Cassandra servers
#  Array of strings value.
#  Defaults to hiera('contrail::cassandra_server_list')
#
# [*contrail_analytics_vip*]
#  (optional) VIP of Contrail Analytics
#  String (IPv4) value.
#  Defaults to hiera('contrail_analytics_vip',hiera('internal_api_virtual_ip'))
#
# [*contrail_config_vip*]
#  (optional) VIP of Contrail Config
#  String (IPv4) value.
#  Defaults to hiera('contrail_config_vip',hiera('internal_api_virtual_ip'))
#
# [*contrail_webui_http_port*]
#  (optional) Webui HTTP Port
#  Integer value.
#  Defaults to 8080
#
# [*contrail_webui_https_port*]
#  (optional) Webui HTTPS Port
#  Integer value.
#  Defaults to 8143
#
# [*neutron_vip*]
#  (optional) VIP of Neutron
#  String (IPv4) value.
#  Defaults to hiera('internal_api_virtual_ip')
#
# [*redis_ip*]
#  (optional) IP of Redis
#  String (IPv4) value.
#  Defaults to '127.0.0.1'
#
# [*ssl_enabled*]
#  (optional) SSL should be used in internal Contrail services communications
#  Boolean value.
#  Defaults to hiera('contrail_ssl_enabled', false)
#
# [*ca_file*]
#  (optional) ca file name
#  String value.
#  Defaults to hiera('contrail::service_cert_file',false)
#
# [*cert_file*]
#  (optional) cert file name
#  String value.
#  Defaults to hiera('contrail::service_cert_file',false)
#
# [*key_file*]
#  (optional) key file name
#  String value.
#  Defaults to hiera('contrail::service_key_file',false)
#
class tripleo::network::contrail::webui(
  $step                      = hiera('step'),
  $admin_password            = hiera('contrail::admin_password'),
  $admin_tenant_name         = hiera('contrail::admin_tenant_name'),
  $admin_token               = hiera('contrail::admin_token'),
  $admin_user                = hiera('contrail::admin_user'),
  $auth_host                 = hiera('contrail::auth_host_internal', hiera('internal_api_virtual_ip')),
  $auth_port                 = hiera('contrail::auth_port_internal'),
  $auth_protocol             = hiera('contrail::auth_protocol_internal'),
  $auth_version              = hiera('contrail::auth_version',2),
  $cassandra_server_list     = hiera('contrail_database_node_ips'),
  $contrail_analytics_vip    = hiera('contrail_analytics_vip', hiera('internal_api_virtual_ip')),
  $contrail_config_vip       = hiera('contrail_config_vip', hiera('internal_api_virtual_ip')),
  $contrail_version          = hiera('contrail::contrail_version',4),
  $contrail_webui_http_port  = hiera('contrail::webui::http_port'),
  $contrail_webui_https_port = hiera('contrail::webui::https_port'),
  $neutron_vip               = hiera('internal_api_virtual_ip'),
  $redis_ip                  = hiera('contrail::webui::redis_ip'),
  $ssl_enabled               = hiera('contrail_ssl_enabled', false),
  $ca_file                   = hiera('contrail::ca_cert_file', undef),
  $key_file                  = hiera('contrail::service_key_file', undef),
  $cert_file                 = hiera('contrail::service_cert_file', undef),
)
{
  if $step >= 5 {
    # todo: it is actually is used as CA file for identity manager
    $cert_file_todo = undef
    if $contrail_version < 4 {
      $introspect_ssl_enable = false
      $cnfg_auth_protocol = 'http'
    } else {
      $introspect_ssl_enable = $ssl_enabled
      $cnfg_auth_protocol = $auth_protocol
    }
    class {'::contrail::webui':
      admin_user                => $admin_user,
      admin_password            => $admin_password,
      admin_token               => $admin_token,
      admin_tenant_name         => $admin_tenant_name,
      auth_port                 => $auth_port,
      auth_protocol             => $auth_protocol,
      auth_version              => $auth_version,
      cassandra_ip              => $cassandra_server_list,
      cert_file                 => $cert_file_todo,
      contrail_config_vip       => $contrail_config_vip,
      contrail_analytics_vip    => $contrail_analytics_vip,
      contrail_webui_http_port  => $contrail_webui_http_port,
      contrail_webui_https_port => $contrail_webui_https_port,
      neutron_vip               => $neutron_vip,
      openstack_vip             => $auth_host,
      redis_ip                  => $redis_ip,
      introspect_ssl_enable     => $introspect_ssl_enable,
      cnfg_auth_protocol        => $cnfg_auth_protocol,
      sandesh_keyfile           => $key_file,
      sandesh_certfile          => $cert_file,
      sandesh_ca_cert           => $ca_file,
    }
  }
}