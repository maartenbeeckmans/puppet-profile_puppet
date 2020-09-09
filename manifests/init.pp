#
#
#
class profile_puppetmaster (
  Boolean         $autosign          = false,
  Array[String]   $autosign_entries  = [],
  Boolean         $setup_foreman     = false,
  String          $version           = 'latest',
  Boolean         $setup_puppetdb    = false,
  Boolean         $setup_puppetboard = false,
) {
  # @TODO implement prometheus/graphite metrics
  if $setup_puppetdb {
    $server_storeconfigs = true
    $server_reports = 'puppetdb'
    include profile_puppetmaster::puppetdb
  } else {
    $server_storeconfigs = false
    $server_reports = 'foreman'
  }
  class { 'puppet':
    server               => true,
    autosign             => $autosign,
    autosign_entries     => $autosign_entries,
    server_foreman       => $setup_foreman,
    version              => $version,
    server_multithreaded => true,
    server_storeconfigs  => $server_storeconfigs,
    server_reports       => $server_reports,

  }
  if $setup_puppetboard {
    include profile_puppetmaster::puppetboard
  }
}
