class gnome_desktop {
  # diff="colordiff -Nu '%s' '%s' | less --no-init --QUIT-AT-EOF -R"
  # merge="vimdiff -c 'saveas '%s'' -c next -c 'setlocal noma readonly' -c prev '%s' '%s'"
  # replace-wscomments=yes
  # replace-unmodified=yes
  file { '/etc/dispatch-conf.conf':
    source => 'puppet:///modules/module/dispatch-conf.conf',
    mode   => 644,
  }

  # Defaults:mitko timestamp_timeout=560 # min before asking for password again
  file { '/etc/sudoers':
    source => 'puppet:///modules/module/sudoers',
    mode   => 440,
  }

  package { 'app-editors/gvim':
    ensure => latest,
  }

  package { 'dev-vcs/git':
    ensure => latest,
  }

  exec { 'git-config':
    command     => ['git config --global user.name "Dimitar Dimitrov"',
                    'git config --global user.email mitkofr@yahoo.fr',
                    'git config --global color.ui true'],
    refreshonly => true,
  }

  package { 'net-print/cups':
    ensure => latest,
  }

  service { 'cupsd':
    ensure     => stopped,
    enable     => false,
    hasrestart => true,
    hasstatus  => true,
  }

  package { 'net-misc/ntp':
    ensure => latest,
  }

  service { 'ntpd':
    name       => 'ntpd',
    ensure     => running,
    enable     => true,
    hasrestart => true,
  }

  Package['dev-vcs/git'] ~> Exec['git-config']
  Package['net-misc/ntp'] -> Service['ntpd']
  Package['net-print/cups'] -> Service['cupsd']
}
