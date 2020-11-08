#
#
#
class profile_puppetmaster (
  Boolean         $autosign                 = false,
  Array[String]   $autosign_entries         = [],
  String          $server_jvm_min_heap_size = '2G',
  String          $server_jvm_max_heap_size = '2G',
  String          $version                  = 'latest',
  Boolean         $setup_puppetdb           = false,
  Boolean         $setup_puppetboard        = false,
  Boolean         $manage_firewall_entry    = true,
  Hash            $repositories             = {},
) {
  # @TODO implement prometheus/graphite metrics
  if $setup_puppetdb {
    $server_storeconfigs = true
    $server_reports = 'puppetdb'
    include profile_puppetmaster::puppetdb
  } else {
    $server_storeconfigs = false
    $server_reports = 'store'
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
  if $setup_puppetboard {
    include profile_puppetmaster::puppetboard
  }
  create_resources('vscrepo', $repositories)
}
