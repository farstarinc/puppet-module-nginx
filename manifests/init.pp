class nginx($worker_processes=1, $ensure=present) {
  package { nginx:
    ensure => $ensure ? {
      'present' => $ensure,
      'absent' => purged,
    },
  }

  file {
    "/etc/nginx/nginx.conf":
      ensure => $ensure,
      content => template("nginx/nginx.conf.erb"),
      require => Package[nginx];

    "/etc/logrotate.d/nginx":
      ensure => $ensure,
      source => "puppet:///modules/nginx/nginx.logrotate",
      require => Package[nginx];

    "/etc/nginx/sites-enabled/default":
      ensure => absent,
      require => Package[nginx],
      notify => Service[nginx];
  }

  service { nginx:
    ensure => $ensure ? {
      'present' => running,
      'absent' => stopped,
    },
    enable => $ensure ? {
      'present' => true,
      'absent' => false,
    },
    pattern => "nginx: master process",
    subscribe => File["/etc/nginx/nginx.conf"],
    require => [File["/etc/nginx/nginx.conf"],
                File["/etc/logrotate.d/nginx"]],
  }
}
