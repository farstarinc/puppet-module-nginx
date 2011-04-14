class nginx($worker_processes=1) {
  package { nginx:
    ensure => present,
  }

  file {
    "/etc/nginx/nginx.conf":
      content => template("nginx/nginx.conf.erb"),
      require => Package[nginx];

    "/etc/logrotate.d/nginx":
      source => "puppet:///modules/nginx/nginx.logrotate",
      require => Package[nginx];

    "/etc/nginx/sites-enabled/default":
      ensure => absent,
      require => Package[nginx],
      notify => Service[nginx];
  }

  service { nginx:
    ensure => running,
    enable => true,
    pattern => "nginx: master process",
    subscribe => File["/etc/nginx/nginx.conf"],
    require => [File["/etc/nginx/nginx.conf"],
                File["/etc/logrotate.d/nginx"]],
  }
}
