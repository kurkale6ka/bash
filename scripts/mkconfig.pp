# diff="colordiff -Nu '%s' '%s' | less --no-init --QUIT-AT-EOF -R"
# merge="vimdiff -c 'saveas '%s'' -c next -c 'setlocal noma readonly' -c prev '%s' '%s'"
# replace-wscomments=yes
# replace-unmodified=yes
file { '/etc/dispatch-conf.conf':
  source => 'puppet://path',
  mode   => mode,
}

# Defaults:mitko timestamp_timeout=560 # min before asking for password again
file { '/etc/sudoers':
  source => 'puppet://path',
  mode   => mode,
}

# git config --global user.name 'Dimitar Dimitrov'
# git config --global user.email 'mitkofr@yahoo.fr'
# git config --global color.ui true

package { 'app-editors/gvim':
  ensure => present,
}

package { 'net-print/cups':
  ensure => present,
}

service { 'cupsd':
  ensure     => stopped,
  enable     => false,
  hasrestart => true,
  hasstatus  => true,
}

package { 'net-misc/ntp':
  ensure => present,
}

service { 'ntpd':
  name       => 'ntpd',
  ensure     => running,
  enable     => true,
  hasrestart => true,
}

Package['net-misc/ntp'] -> Service['ntpd']
Package['net-print/cups'] -> Service['cupsd']
