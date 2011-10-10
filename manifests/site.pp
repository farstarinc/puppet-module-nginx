define nginx::site($domain,
                   $root,
                   $ensure=present,
                   $owner=undef,
                   $group=undef,
                   $static_dirs=[],
                   $mediaprefix="",
                   $default_vhost=false,
                   $rewrite_missing_html_extension=false,
                   $upstreams=[],
                   $aliases=[]) {

  if $ensure == 'present' {
    
    file { $root:
      ensure => directory,
      owner => $owner,
      group => $group,
    }

  } elsif $ensure == 'absent' {

    file { $root:
      ensure => $ensure,
      owner => $owner,
      group => $group,
      recurse => true,
      purge => true,
      force => true,
    }
  }

  file {
    "/etc/nginx/sites-available/${name}.conf":
      ensure => $ensure,
      content => template("nginx/site.conf.erb"),
      require => [File[$root],
                  Package[nginx]],
      notify => Service[nginx];

    "/etc/nginx/sites-enabled/${name}.conf":
      ensure => $ensure ? {
        'present' => link,
        'absent' => $ensure,
      },
      target => $ensure ? {
        'present' => "/etc/nginx/sites-available/${name}.conf",
        'absent' => notlink,
      },
      require => File["/etc/nginx/sites-available/${name}.conf"],
      notify => Service[nginx];
  }
}
