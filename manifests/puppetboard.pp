#
#
#
class profile_puppetmaster::puppetboard (
  Boolean $manage_sd_service = $::profile_puppetmaster::manage_sd_service,
  String  $sd_service_name   = $::profile_puppetmaster::sd_service_name,
  Array   $sd_service_tags   = $::profile_puppetmaster::sd_service_tags,
) {
  class { 'puppetboard':
    manage_git          => true,
    manage_virtualenv   => true,
    reports_count       => 150,
    offline_mode        => true,
    default_environment => '*',
  }
  class { 'apache':
    default_vhost => false,
    purge_configs => true,
  }
  $wsgi = $facts['os']['family'] ? {
    'Debian' => {
      package_name => 'libapache2-mod-wsgi-py3',
      mod_path     => '/usr/lib/apache2/modules/mod_wsgi.so'
    },
    default  => {},
  }
  class { 'apache::mod::wsgi':
    * => $wsgi,
  }
  class { 'puppetboard::apache::vhost':
    vhost_name => 'localhost',
    port       => 80,
  }
  firewall { '00080 allow puppetboard':
    dport  => 80,
    action => 'accept',
  }
  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => 'http://localhost:80',
          interval => '10s'
        }
      ],
      port   => 80,
      tags   => $sd_service_tags,
    }
  }
}
