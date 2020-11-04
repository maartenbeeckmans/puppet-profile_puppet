#
#
#
class profile_puppetmaster::puppetboard (
  Boolean       $manage_sd_service     = false,
  String        $sd_service_name       = 'puppetboard',
  Array         $sd_service_tags       = [],
) {
  class { 'puppetboard':
    manage_git          => true,
    manage_virtualenv   => true,
    reports_count       => 150,
    offline_mode        => true,
    default_environment => '*',
  }
  firewall { '08080 allow puppetboard':
    dport  => 8080,
    action => 'accept',
  }
  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => 'http://localhost:8080',
          interval => '10s'
        }
      ],
      port   => 8080,
      tags   => $sd_service_tags,
    }
  }
}
