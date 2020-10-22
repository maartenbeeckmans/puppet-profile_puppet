#
#
#
class profile_puppetmaster::puppetboard {
  class { 'puppetboard':
    manage_git          => 'latest',
    manage_virtualenv   => 'latest',
    reports_count       => 150,
    offline_mode        => true,
    default_environment => '*',
  }
  class { 'apache':
    default_vhost => false,
    purge_configs => true,
  }
  $wsgi = $facts['os']['family'] ? {
    'Debian' => {package_name => "libapache2-mod-wsgi-py3", mod_path => "/usr/lib/apache2/modules/mod_wsgi.so"},
    default  => {},
  }
  class { 'apache::mod::wsgi':
    * => $wsgi,
  }
  class { 'puppetboard::apache::vhost':
    vhost_name => 'localhost',
    port       => 80,
  }
}
