#
#
#
class profile_puppet (
  Boolean                 $server,
  String                  $version,
  Optional[String]        $puppetmaster,
  Boolean                 $use_srv_records,
  Optional[String]        $srv_domain,
  Boolean                 $autosign,
  Array[String]           $autosign_entries,
  String                  $server_jvm_min_heap_size,
  String                  $server_jvm_max_heap_size,
  Optional[String]        $puppetdb_host,
  Boolean                 $install_vault,
  Boolean                 $manage_firewall_entry,
  Boolean                 $manage_puppet_reporter,
  String                  $server_sd_service_name,
  Array[String]           $server_sd_service_tags,
  Optional[Array[String]] $puppetdb_allowed_ips,
  Boolean                 $manage_puppetdb_exporter,
  Boolean                 $puppetdb_manage_database,
  String                  $puppetdb_database_host,
  String                  $puppetdb_database_name,
  String                  $puppetdb_database_user,
  String                  $puppetdb_database_password,
  String                  $puppetdb_database_grant,
  String                  $puppetdb_listen_address,
  String                  $puppetdb_ssl_listen_address,
  Boolean                 $puppetdb_install_client_tools,
  String                  $puppetdb_sd_service_name,
  Array[String]           $puppetdb_sd_service_tags,
  Boolean                 $manage_sd_service        = lookup('manage_sd_service', Boolean, first, true),
) {
  if $puppetdb_host {
    $_server_storeconfigs = true
    if $manage_puppet_reporter {
      $_server_reports = 'puppetdb,prometheus'
    } else {
      $_server_reports = 'puppetdb'
    }
  } else {
    $_server_storeconfigs = false
    if $manage_puppet_reporter {
      $_server_reports = 'store,prometheus'
    } else {
      $_server_reports = 'store'
    }
  }

  class { 'puppet':
    agent                    => true,
    server                   => $server,
    version                  => $version,
    show_diff                => true,
    puppetmaster             => $puppetmaster,
    use_srv_records          => $use_srv_records,
    srv_domain               => $srv_domain,
    autosign                 => $autosign,
    autosign_entries         => $autosign_entries,
    server_storeconfigs      => $_server_storeconfigs,
    server_reports           => $_server_reports,
    server_foreman           => false,
    server_external_nodes    => '',
    server_multithreaded     => true,
    server_jvm_min_heap_size => $server_jvm_min_heap_size,
    server_jvm_max_heap_size => $server_jvm_max_heap_size,
    runmode                  => 'systemd.timer',
  }

  if $server {
    include profile_puppet::server
  }
}
