#
#
#
class profile_puppetmaster (
  Boolean         $autosign          = false,
  Array['String'] $autosign_entries  = [],
  Boolean         $setup_foreman     = false,
  String          $version           = 'latest',
  Boolean         $setup_puppetdb    = false,
  Boolean         $setup_puppetboard = false,
) {
  # @TODO implement prometheus/graphite metrics
  class { 'puppet::server':
    autosign         => $autosign,
    autosign_entries => $autosign_entries,
    foreman          => $setup_foreman,
    version          => $version,
    multithreaded    => true,
  }
  if $setup_puppetdb {
    include profile_puppetmaster::puppetdb
  }
  if $setup_puppetboard {
    include profile_puppetmaster::puppetboard
  }
}
