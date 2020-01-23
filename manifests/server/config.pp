class teamcity::server::config(
  $init_config,
  $server_xml
) {

  File {
    owner   => $teamcity::server::user,
    group   => $teamcity::common::group,
    mode    => '0755',
  }

  file {
    $teamcity::server::home_dir:
      ensure => directory;
    $teamcity::server::log_dir:
      ensure => directory;
    $teamcity::server::data_dir:
      ensure => directory;
    $teamcity::server::plugin_dir:
      ensure => directory,
  }
  
  file { "${teamcity::server::home_dir}/conf/server.xml":
    ensure  => present,
    content => $server_xml,
    mode    => '0644',
    owner   => $teamcity::server::user,
    group   => $teamcity::common::group,
  }

  file { "/etc/init.d/${teamcity::server::service}":
    ensure  => present,
    content => $init_config,
    mode    => '0755',
    owner   => root,
    group   => root,
    notify  => Service[$teamcity::server::service],
    require => File["${teamcity::server::home_dir}/conf/server.xml"],
  }
}
