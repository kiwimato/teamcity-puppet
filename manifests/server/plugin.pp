# Define: teamcity::server::plugin
#
# This is a defined type to a teamcity plugin
#
# == Parameters
# [*ensure*]
#   Allows creation or removal of swapspace and the corresponding file.
# [*swapfile*]
#   Location of swapfile, defaults to /mnt
# [*plugin_url*]
#   web location of plugin to dowload 
# [*plugin_zip_file*]
#   file name to store plugin in teamcity plugin directory
# [*wget_opts*]
#   wget opts to use  
#
# == Example
#
#    teamcity::server::plugins { 'node':
#      plugin_url       => 'http://teamcity.jetbrains.com/guestAuth/repository/download/bt434/.lastSuccessful/jonnyzzz.node.zip',
#      plugin_zip_file  => 'jonnyzzz.node.zip',
#      wget_opts        => "-e use_proxy=yes -e http_proxy=http://mycompanyproxy.com:3128",
#      require          => Class['teamcity::server'],
#    }
#
#
define teamcity::server::plugin (
  $ensure           = 'present',
  $plugin_url       = '',
  $plugin_zip_file  = '',
  $wget_opts        = ''
)
{
  # Parameter validation
  validate_re($ensure, ['^absent$', '^present$'], "Invalid ensure: ${ensure} - (Must be 'present' or 'absent')")

  if $ensure == 'present' {
    exec { "download teamcity plugin ${plugin_url}":
      command => "wget ${wget_opts} \"${plugin_url}\"",
      creates => "${teamcity::server::plugin_dir}/${plugin_zip_file}",
      cwd     => $teamcity::server::plugin_dir,
      notify  => Exec["restart teamcity service to add ${plugin_zip_file}"],
      timeout => 0
    }
  
    exec { "set ownership teamcity plugin ${plugin_zip_file}":
      command => "chown ${teamcity::server::user}:${teamcity::common::group} \"${teamcity::server::plugin_dir}/${plugin_zip_file}\"",
      cwd     => $teamcity::server::plugin_dir,
      require => Exec["download teamcity plugin ${plugin_url}"],
      timeout => 0
    }
  
    exec { "restart teamcity service to add ${plugin_zip_file}":
      command     => "service ${teamcity::server::service} restart",
      cwd         => $teamcity::server::home_dir,
      refreshonly => true,
      timeout     => 0
    }
  }
  elsif $ensure == 'absent' {
    file { "${teamcity::server::plugin_dir}/${plugin_zip_file}":
      ensure  => absent,
      backup  => false,
      notify  => Exec["restart teamcity service to remove plugin ${plugin_zip_file}"],
    }
    
    exec { "restart teamcity service to remove plugin ${plugin_zip_file}":
      command     => "service ${teamcity::server::service} restart",
      cwd         => $teamcity::server::home_dir,
      refreshonly => true,
      timeout     => 0
    }
  }

}