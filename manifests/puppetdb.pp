#
#
#
class profile_puppet::puppetdb (
  Optional[Array[String]] $puppetdb_allowed_ips     = $::profile_puppet::puppetdb_allowed_ips,
  Boolean                 $manage_firewall_entry    = $::profile_puppet::manage_firewall_entry,
  Boolean                 $manage_puppetdb_exporter = $::profile_puppet::manage_puppetdb_exporter,
  Boolean                 $manage_database          = $::profile_puppet::puppetdb_manage_database,
  String                  $database_host            = $::profile_puppet::puppetdb_database_host,
  String                  $database_name            = $::profile_puppet::puppetdb_database_name,
  String                  $database_user            = $::profile_puppet::puppetdb_database_user,
  String                  $database_password        = $::profile_puppet::puppetdb_database_password,
  String                  $database_grant           = $::profile_puppet::puppetdb_database_grant,
  String                  $listen_address           = $::profile_puppet::puppetdb_listen_address,
  String                  $ssl_listen_address       = $::profile_puppet::puppetdb_ssl_listen_address,
  Boolean                 $install_client_tools     = $::profile_puppet::puppetdb_install_client_tools,
  Boolean                 $manage_sd_service        = $::profile_puppet::manage_sd_service,
  String                  $sd_service_name          = $::profile_puppet::puppetdb_sd_service_name,
  Array[String]           $sd_service_tags          = $::profile_puppet::puppetdb_sd_service_tags,
  ) {
  class { 'puppetdb::server':
    manage_firewall    => 'false',
    database_host      => $database_host,
    database_name      => $database_name,
    database_username  => $database_user,
    database_password  => $database_password,
    listen_address     => $listen_address,
    ssl_listen_address => $ssl_listen_address,
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
      ensure   => installed,
      provider => puppet_gem,
    }
  }

  if $manage_puppetdb_exporter {
    include profile_prometheus::puppetdb_exporter
  }

  if $manage_database {
    profile_postgres::database { $database_name:
      user     => $database_user,
      password => $database_password,
    }
  }

  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => "http://${facts[networking][ip]}:8080/status/v1/services/puppetdb-status",
          interval => '10s'
        }
      ],
      port   => 8080,
      tags   => $sd_service_tags,
    }
  }
}
