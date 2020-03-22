class tripleo::network::contrail::logrotate_config (
  $step             = Integer(hiera('step')),
  $ensure           = present,
  $minute           = 0,
  $hour             = '*',
  $monthday         = '*',
  $month            = '*',
  $weekday          = '*',
  Integer $maxdelay = 90,
  $user             = 'root',
  $copytruncate     = true,
  $delaycompress    = true,
  $compress         = true,
  $rotation         = 'daily',
  $maxsize          = '10M',
  $rotate           = 14,
  $purge_after_days = 14,
  $dateext          = undef,
  $dateformat       = undef,
  $dateyesterday    = undef,
  # DEPRECATED PARAMETERS
  $size             = undef,
) {

# we add contrail config section on next step after config creation on step >= 4
# https://github.com/openstack/puppet-tripleo/blob/stable/queens/manifests/profile/base/logging/logrotate.pp#L124
# TODO: don't guess wright step to edit config after its creation, do global depending.
# TODO: do edit config file if there is hiera item: contrail log path regex.
  if $step == 5 {
    if ($size != undef) {
      warning('The size parameter is DISABLED to enforce GDPR.')
      warning('Size configures maxsize instead of size.')
      $maxsize = pick($size, $maxsize)
    }

    $config = "/etc/logrotate-crond.conf"

    exec {"logrotate_config_file_exists":
      command => "/bin/true",
      onlyif => "test -f '${config}'",
      path => ['/usr/bin','/usr/sbin','/bin','/sbin'],
    }

    if $logrotate_config_file_exists {

      $new_config = "/etc/temp_logrotate-crond.conf"

      file { "${new_config}":
        ensure  => file,
        owner   => $user,
        group   => $user,
        mode    => '0640',
        content => template('tripleo/contrail/contrail_logrotate_config.conf.erb'),
      }

      exec {"add_openstack_section_to_new_config":
        command => "cat '${config}' >> '${new_config}' && mv -f '${new_config}' '${config}'",
        path => ['/usr/bin','/usr/sbin','/bin','/sbin'],
      }
      
    }



}
