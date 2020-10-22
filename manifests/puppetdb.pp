#
#
#
class profile_puppetmaster::puppetdb {
  # Configure puppetdb and postgres
  class { 'puppetdb':
    manage_package_repo => true,
  }

  # Configure the puppetmaster to use puppetdb
  class {'puppet::server::puppetdb':
    server => $facts['networking']['fqdn'],
  }
}
