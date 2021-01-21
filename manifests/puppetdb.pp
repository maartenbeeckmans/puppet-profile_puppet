#
#
#
class profile_puppetmaster::puppetdb (
  String                  $puppetdb_host            = $::profile_puppetmaster::puppetdb_host,
  Optional[Array[String]] $puppetdb_allowed_ips     = $::profile_puppetmaster::puppetdb_allowed_ips,
  Boolean                 $manage_firewall_entry    = $::profile_puppetmaster::manage_firewall_entry,
  Boolean                 $manage_puppetdb_exporter = $::profile_puppetmaster::manage_puppetdb_exporter,
  ) {
  # Configure puppetdb and postgres
  class { 'puppetdb':
    manage_package_repo => true,
    java_args           => {
      '-Xmx' => '1024m',
    },
    listen_address      => '0.0.0.0',
    manage_firewall     => 'false',
    node_ttl            => '30d',
    node_purge_ttl      => '30d',
  }

  # Configure the puppetmaster to use puppetdb
  class {'puppet::server::puppetdb':
    server => $puppetdb_host,
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

  if $manage_puppetdb_exporter {
    include profile_prometheus::puppetdb_exporter
  }
}
