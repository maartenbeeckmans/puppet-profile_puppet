#
#
#
class profile_puppetmaster (
  Boolean                 $autosign,
  Array[String]           $autosign_entries,
  String                  $server_jvm_min_heap_size,
  String                  $server_jvm_max_heap_size,
  String                  $version,
  Boolean                 $setup_puppetdb,
  String                  $puppetdb_host,
  Boolean                 $manage_puppetdb_exporter,
  Boolean                 $manage_puppet_reporter,
  Boolean                 $setup_puppetboard,
  Boolean                 $manage_firewall_entry,
  Optional[Array[String]] $puppetdb_allowed_ips     = undef,
) {
  if $setup_puppetdb {
    $server_storeconfigs = true
    if $manage_puppet_reporter {
      $server_reports = 'puppetdb,prometheus'
    } else {
      $server_reports = 'puppetdb'
    }
    include profile_puppetmaster::puppetdb
  } else {
    $server_storeconfigs = false
    if $manage_puppet_reporter {
      $server_reports = 'store,prometheus'
    } else {
      $server_reports = 'store'
    }
  }
  if $manage_puppet_reporter {
    file { '/etc/puppetlabs/puppet/prometheus.yaml':
      source => 'puppet:///modules/profile_puppetmaster/prometheus.yaml',
    }
  }
  class { 'puppet':
    server                   => true,
    autosign                 => $autosign,
    autosign_entries         => $autosign_entries,
    server_foreman           => false,
    version                  => $version,
    server_multithreaded     => true,
    server_storeconfigs      => $server_storeconfigs,
    server_reports           => $server_reports,
    server_external_nodes    => '',
    server_jvm_min_heap_size => $server_jvm_min_heap_size,
    server_jvm_max_heap_size => $server_jvm_max_heap_size,
  }
  if $manage_firewall_entry {
    firewall { '08140 allow puppetmaster':
      dport  => 8140,
      action => 'accept',
    }
  }
}
