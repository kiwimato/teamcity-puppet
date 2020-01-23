class teamcity::server::install(
    $download_dir       = '/tmp',
    $wget_opts          = '',
) {

  exec { 'download_team_city':
    command => "wget ${wget_opts} \"http://download.jetbrains.com/teamcity/TeamCity-${teamcity::server::team_city_version}.tar.gz\"",
    creates => "${download_dir}/TeamCity-${teamcity::server::team_city_version}.tar.gz",
    path => ['/bin/', '/sbin', '/usr/bin'],
    cwd     => $download_dir,
    timeout => 0
  }

  exec { 'explode_team_city':
    command => "tar xvf TeamCity-${teamcity::server::team_city_version}.tar.gz -C ${teamcity::server::install_dir}",
    creates => $teamcity::server::home_dir,
    path => ['/bin/', '/sbin', '/usr/bin'],
    cwd     => $download_dir,
    require => Exec['download_team_city']
  }

  exec { "chown -R ${teamcity::server::user}:${teamcity::common::group} ${teamcity::server::home_dir}":
    command => "chown -R ${teamcity::server::user}:${teamcity::common::group} ${teamcity::server::home_dir}",
    path => ['/bin/', '/sbin', '/usr/bin'],
    cwd     => $download_dir,
    require => Exec['explode_team_city']
  }
}
  