#
#
#
class profile_puppet (
  Boolean                 $server,
  String                  $version,
  Optional[String]        $puppetmaster,
  Optional[String]        $ca_server,
  Boolean                 $use_srv_records,
  Optional[String]        $srv_domain,
  Boolean                 $autosign,
  Array[String]           $autosign_entries,
  Optional[String]        $server_jvm_min_heap_size,
  Optional[String]        $server_jvm_max_heap_size,
  Optional[String]        $puppetdb_host,
  Boolean                 $install_vault,
  Boolean                 $manage_firewall_entry,
  Boolean                 $manage_puppet_reporter,
  Boolean                 $server_ca,
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

  if $server_jvm_min_heap_size and $server_jvm_max_heap_size {
    $_server_jvm_min_heap_size = $server_jvm_min_heap_size
    $_server_jvm_max_heap_size = $server_jvm_max_heap_size
  } else {
    $_server_jvm_min_heap_size = "${1024 + $facts['processors']['count'] * 512}m"
    $_server_jvm_max_heap_size = "${1024 + $facts['processors']['count'] * 512}m"
  }

  class { 'puppet':
    agent                                  => true,
    server                                 => $server,
    version                                => $version,
    show_diff                              => true,
    puppetmaster                           => $puppetmaster,
    ca_server                              => $ca_server,
    use_srv_records                        => $use_srv_records,
    srv_domain                             => $srv_domain,
    autosign                               => $autosign,
    autosign_entries                       => $autosign_entries,
    dns_alt_names                          => split($facts['dns_alt_names'], /,/),
    splay                                  => true,
    splaylimit                             => '1800s',
    server_common_modules_path             => [],
    server_environments_owner              => 'root',
    server_environments_group              => 'root',
    server_ca                              => $server_ca,
    server_storeconfigs                    => $_server_storeconfigs,
    server_reports                         => $_server_reports,
    server_ca_allow_sans                   => true,
    server_foreman                         => false,
    server_external_nodes                  => '',
    server_multithreaded                   => true,
    server_jvm_min_heap_size               => $_server_jvm_min_heap_size,
    server_jvm_max_heap_size               => $_server_jvm_max_heap_size,
    server_jvm_extra_args                  => [
      '-XX:ReservedCodeCacheSize=512m',
      ' -Djruby.logger.class=com.puppetlabs.jruby_utils.jruby.Slf4jLogger'
    ],
    server_environment_class_cache_enabled => true,
    server_environment_timeout             => 'unlimited',
    server_strict_variables                => true,
    runmode                                => 'systemd.timer',
  }

  if $server {
    include profile_puppet::server
  }
}
