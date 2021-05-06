#
#
#
class profile_puppet::server (
  String        $puppetdb_host          = $::profile_puppet::puppetdb_host,
  Boolean       $install_vault          = $::profile_puppet::install_vault,
  Boolean       $manage_firewall_entry  = $::profile_puppet::manage_firewall_entry,
  Boolean       $manage_puppet_reporter = $::profile_puppet::manage_puppet_reporter,
  Boolean       $manage_sd_service      = $::profile_puppet::manage_sd_service,
  String        $sd_service_name        = $::profile_puppet::server_sd_service_name,
  Array[String] $sd_service_tags        = $::profile_puppet::server_sd_service_tags,
) {
  file { '/etc/puppetlabs/puppet/hiera.yaml':
    mode   => '0644',
    owner  => 'puppet',
    group  => 'puppet',
    source => 'puppet:///modules/profile_puppetmaster/hiera.yaml',
  }

  if $puppetdb_host {
    class { 'puppet::server::puppetdb':
      server => $puppetdb_host,
    }
  }

  if $install_vault {
    package { 'hiera-vault':
      ensure   => present,
      provider => puppetserver_gem,
      notify   => Service['puppetserver'],
    }
  }

  if $manage_firewall_entry {
    firewall { '08140 allow puppetserver':
      dport  => 8140,
      action => 'accept',
    }
  }

  if $manage_puppet_reporter {
    file { '/etc/puppetlabs/puppet/prometheus.yaml':
      source => 'puppet:///modules/profile_puppetmaster/prometheus.yaml',
    }
  }

  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          tcp      => "${facts[networking][ip]}:8140",
          interval => '10s',
        }
      ],
      port   => 8140,
      tags   => $sd_service_tags,
    }
  }
}
