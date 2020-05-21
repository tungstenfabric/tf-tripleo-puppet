
# Contrail Neutron ML2 plugin configuration puppet

class tripleo::network::contrail::neutron_ml2_plugin (
  $step                         = Integer(hiera('step')),
  $api_server                   = hiera('contrail_config_vip', hiera('contrail_config_ips')),
  $api_port                     = hiera('contrail::api_port'),
  $contrail_tls_enabled         = hiera('contrail_tls_enabled', false),
  $insecure                     = hiera('contrail_tls_insecure', true),
  $key_file                     = hiera('contrail_tls_key_file', ''),
  $cert_file                    = hiera('contrail_tls_cert_file', ''),
  $ca_file                      = hiera('contrail_tls_ca_file', ''),
  $contrail_dm_integration      = hiera('contrail_dm_integration', false),
) {
  include ::neutron::deps

  File<| |> -> Ini_setting<| |>

  $config_dir = '/etc/neutron/plugins/ml2'
  $config_path = "${config_dir}/ml2_conf_opencontrail.ini"

  ensure_resource('file', $config_dir, {
    ensure => directory,
    owner  => 'root',
    group  => 'neutron',
    mode   => '0640'}
  )

  $plugin_config = {
    'APISERVER' => {
      'api_server_ip'   => $api_server,
      'api_server_port' => $api_port,
      'use_ssl'         => $contrail_tls_enabled,
      'insecure'        => $insecure,
      'certfile'        => $key_file,
      'keyfile'         => $cert_file,
      'cafile'          => $ca_file,
    },
    'DM_INTEGRATION' => {
      'enabled' => $contrail_dm_integration,
    },
  }

  create_ini_settings($plugin_config, { 'path' => $config_path })

  file { '/etc/neutron/plugin.ini':
    ensure => link,
    target => $config_path,
    tag    => 'neutron-config-file',
  }
}
