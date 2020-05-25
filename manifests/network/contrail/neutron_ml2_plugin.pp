
# Contrail Neutron ML2 plugin configuration puppet

class tripleo::network::contrail::neutron_ml2_plugin (
  $step                         = Integer(hiera('step')),
  $api_server                   = hiera('contrail_config_ips', hiera('internal_api_virtual_ip')),
  $api_port                     = hiera('contrail::api_port'),
  $use_ssl                      = hiera('contrail_ssl_enabled', false),
  $insecure                     = hiera('contrail_ssl_insecure', true),
  $key_file                     = hiera('contrail::service_key_file', ''),
  $cert_file                    = hiera('contrail::service_cert_file', ''),
  $ca_file                      = hiera('contrail::auth_ca_file', ''),
  $contrail_dm_integration      = hiera('contrail_dm_integration', false),
) {
  include ::neutron::deps

  File<| |> -> Ini_setting<| |>

  $plugin_config = {
    'APISERVER' => {
      'api_server_ip'   => $api_server,
      'api_server_port' => $api_port,
      'use_ssl'         => $use_ssl,
      'insecure'        => $insecure,
      'certfile'        => $key_file,
      'keyfile'         => $cert_file,
      'cafile'          => $ca_file,
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
}
