#
#
#
class profile_puppetmaster::puppetdb {
  # Configure puppetdb and postgres
  class { 'puppetdb': }
  # Configure the puppetmaster to use puppetdb
  class { 'puppetdb::master::config': }
}
