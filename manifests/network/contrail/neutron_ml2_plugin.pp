
# Contrail Neutron ML2 plugin configuration puppet

class tripleo::network::contrail::neutron_ml2_plugin (
  $step                           = Integer(hiera('step')),
  $api_server                     = hiera('contrail_config_ips', hiera('internal_api_virtual_ip')),
  $api_port                       = hiera('contrail::api_port'),
  $use_ssl                        = hiera('contrail_ssl_enabled', false),
  $insecure                       = hiera('contrail_ssl_insecure', true),
  $key_file                       = hiera('contrail::service_key_file', ''),
  $cert_file                      = hiera('contrail::service_cert_file', ''),
  $ca_file                        = hiera('contrail::auth_ca_file', ''),
  $contrail_dm_integration        = hiera('contrail_dm_integration', false),
  $contrail_management_port_tags  = hiera('contrail_management_port_tags', []),
  $contrail_data_port_tags        = hiera('contrail_data_port_tags', []),
  $internal_api_ssl               = hiera('contrail_internal_api_ssl', false),
  $auth_protocol                  = hiera('contrail::auth_protocol'),
  $auth_host                      = hiera('contrail::auth_host'),
  $auth_port                      = hiera('contrail::auth_port'),
  $admin_user                     = hiera('contrail::admin_user'),
  $admin_password                 = hiera('contrail::admin_password'),
  $admin_tenant_name              = hiera('contrail::admin_tenant_name'),
  $keystone_project_domain_name   = hiera('contrail::keystone_project_domain_name','Default'),
) {
  include ::neutron::deps

  File<| |> -> Ini_setting<| |>

  # neutron is executed at $step >= 3
  if $step >= 4 {

    ensure_resource('file', '/etc/contrail', {
      ensure => directory,
      owner  => 'root',
      group  => 'neutron',
      mode   => '0640'}
    )

    $plugin_config = {
      'APISERVER' => {
        'management_port_tags'  => join($contrail_management_port_tags, ','),
        'data_port_tags'        => join($contrail_data_port_tags, ','),
        'api_server_ip'         => $api_server,
        'api_server_port'       => $api_port,
        'use_ssl'               => $use_ssl,
        'insecure'              => $insecure,
        'certfile'              => $key_file,
        'keyfile'               => $cert_file,
        'cafile'                => $ca_file,
      },
      'DM_INTEGRATION' => {
        'enabled' => $contrail_dm_integration,
      },
    }

    $config_dir = '/etc/neutron/plugins/ml2'
    $config_path = "${config_dir}/ml2_conf_opencontrail.ini"
    create_ini_settings($plugin_config, { 'path' => $config_path })

    $config_link = '/etc/neutron/conf.d/neutron-server/ml2_conf_opencontrail.conf'
    file { $config_link:
      ensure  => link,
      target  => $config_path,
      tag     => 'neutron-config-file',
    }

    $vnc_api_lib_config_common = {
      'global' => {
        'WEB_SERVER'  => $api_server,
        'WEB_PORT'    => $api_port,
      },
      'auth' => {
        'AUTHN_TYPE'      => 'keystone',
        'AUTHN_TOKEN_URL' => "${auth_protocol}://${auth_host}:${auth_port}/v3/auth/tokens",
        'AUTHN_DOMAIN'    => $keystone_project_domain_name,
        'AUTHN_TENANT'    => $admin_tenant_name,
        'AUTHN_USER'      => $admin_user,
        'AUTHN_PASSWORD'  => $admin_password,
      },
    }

    if $internal_api_ssl {
      if $ca_file == '' or $insecure {
        $insecure = true
        $cafile_vnc_api = {}
      } else {
        $insecure = false
        $cafile_vnc_api = {
          'global' => {
            'cafile' => $ca_file,
          },
          'auth'   => {
            'cafile' => $ca_file,
          },
        }
      }
      $vnc_api_lib_preconfig_auth_specific = {
        'global' => {
          'insecure' => $insecure,
          'certfile' => $cert_file,
          'keyfile'  => $key_file,
        },
        'auth'   => {
          'insecure'   => $insecure,
          'certfile'   => $cert_file,
          'keyfile'    => $key_file,
        },
      }
      $vnc_api_lib_config_auth_specific = deep_merge($vnc_api_lib_preconfig_auth_specific, $cafile_vnc_api)
    } else {
      $vnc_api_lib_config_auth_specific = {}
    }


    $vnc_api_lib_config = deep_merge($vnc_api_lib_config_common, $vnc_api_lib_config_auth_specific)
    $contrail_vnc_api_lib_config = { 'path' => '/etc/contrail/vnc_api_lib.ini' }
    create_ini_settings($vnc_api_lib_config, $contrail_vnc_api_lib_config)
  }
}
