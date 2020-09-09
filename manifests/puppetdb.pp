#
#
#
class profile_puppetmaster::puppetdb {
  yumrepo { 'postgres-repo':
    ensure   => present,
    baseurl  => 'https://yum.postgresql.org/9.6/redhat/rhel-8-x86_64/',
    enabled  => 1,
    gpgcheck => 0,
  }

  # Configure puppetdb and postgres
  class { 'puppetdb':
    manage_package_repo => false,
  }

  # Configure the puppetmaster to use puppetdb
  class {'puppet::server::puppetdb':
    server => $facts['networking']['fqdn'],
  }
}
