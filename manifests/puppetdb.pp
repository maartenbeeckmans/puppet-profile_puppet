#
#
#
class profile_puppetmaster::puppetdb (
  String                  $puppetdb_host            = $::profile_puppetmaster::puppetdb_host,
  Optional[Array[String]] $puppetdb_allowed_ips     = $::profile_puppetmaster::puppetdb_allowed_ips,
  Boolean                 $manage_firewall_entry    = $::profile_puppetmaster::manage_firewall_entry,
  Boolean                 $manage_puppetdb_exporter = $::profile_puppetmaster::manage_puppetdb_exporter,
  ) {
  class { 'puppetdb::server':
    manage_package_repo => true,
    java_args           => {
      '-Xmx' => '1024m',
    },
    listen_address      => '0.0.0.0',
    manage_firewall     => 'false',
  }


  if $manage_firewall_entry {
    firewall { '18080 puppetdb http reject':
      dport  => 8080,
      proto  => tcp,
      action => reject,
    }

    firewall { '08081 puppetdb https':
      dport  => 8081,
      proto  => tcp,
      action => accept,
    }

    if $puppetdb_allowed_ips {
      $puppetdb_allowed_ips.each |String $allowed_ip| {
        firewall { "08080 puppetdb http accept ${allowed_ip}":
          dport  => 8080,
          proto  => tcp,
          source => $allowed_ip,
          action => accept,
        }
      }
    }
  }
  
  if $install_client_tools {
    package { 'puppetdb_cli':
      ensure          => installed,
      install_options => ['--binddir', '/opt/puppetlabs/bin'],
      provider        => puppet_gem,
    }
  }

  if $manage_puppetdb_exporter {
    include profile_prometheus::puppetdb_exporter
  }

  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => "http://${facts[networking][ip]}:8081",
          interval => '10s'
        }
      ],
      port   => 8081,
      tags   => $sd_service_tags,
    }
  }
}
