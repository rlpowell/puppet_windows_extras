# == Class: windows_extras
#
# Full description of class windows_extras here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { windows_extras:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class windows_extras {
  exec { 'reload explorer':
    refreshonly => true,
    command => "$cmd /c powershell -Command Stop-Process -processname explorer",
  }

  define regload( $file = $title, $unless_key = undef, $unless_value = undef, $unless_check = undef ) {
    $file_quoted = regsubst("\"$file\"", '/', '\\', 'G')

    if $unless_key and $unless_value {
      $unless="$cmd /c reg query \"$unless_key\" /v \"$unless_value\" | findstr /C:\"$unless_check\""
    } elsif $unless_key {
      $unless="$cmd /c reg query \"$unless_key\" | findstr /C:\"$unless_check\""
    } else {
      $unless=undef
    }

    exec { "regload $file":
      command => "$cmd /c regedit /s $file_quoted",
      notify => Exec['reload explorer'],
      unless => $unless,
    }
  }

  # Force this to occur before all package installation, because chocolatey package installation takes forever and when testing it's super annoying to wait that long.
  define windows_conditional_symlink_early( $target, $onlyifexists=undef ) {
    windows_conditional_symlink { $name:
      target       => $target,
      onlyifexists => $onlyifexists
    }

    # Make it come early as promised
    Windows_extras::Windows_conditional_symlink_early[$name] -> Package <| |>
  }

  # Force this to occur before all package installation, because chocolatey package installation takes forever and when testing it's super annoying to wait that long.
  define windows_symlink_early( $target, $mode=undef ) {
    file { $name:
      target       => $target,
      mode         => $mode,
    }

    # Make it come early as promised
    File[$name] -> Package <| |>
  }
}
