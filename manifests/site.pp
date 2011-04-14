define nginx::site($domain,
                   $root,
                   $ensure=present,
                   $mediaroot="",
                   $mediaprefix="",
                   $default_vhost=false,
                   $rewrite_missing_html_extension=false,
                   $upstreams=[],
                   $aliases=[]) {

  if $ensure == 'present' {

    file { $root:
      ensure => directory,
      owner => "www-mgr",
      group => "www-mgr",
    }

    # Parent directory of root directory. /var/www for /var/www/blog
    $root_parent = inline_template("<%= root.match(%r!(.+)/.+!)[1] %>")

    if !defined(File[$root_parent]) {
      file { $root_parent:
        ensure => directory,
      }
    }
  } elsif $ensure == 'absent' {

    file { $root:
      ensure => $ensure,
      owner => "www-mgr",
      group => "www-mgr",
      recurse => true,
      purge => true,
      force => true,
    }
  }

  file {
    "/etc/nginx/sites-available/${name}.conf":
      ensure => $ensure,
      content => template("nginx/site.conf.erb"),
      require => File[$root],
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
