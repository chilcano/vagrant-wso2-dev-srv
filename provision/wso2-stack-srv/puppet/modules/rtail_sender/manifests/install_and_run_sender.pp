class rtail_sender::install_and_run_sender {

  Exec {
    path => ['/usr/bin', '/bin', '/usr/sbin', '/usr/local/bin']
  }

  # Solves the 'nodejs-legacy' issue:
  # http://stackoverflow.com/questions/21168141/can-not-install-packages-using-node-package-manager-in-ubuntu
  
  $packages = ['nodejs', 'nodejs-legacy', 'npm']
  package {
    $packages: ensure => installed
  } ->

  exec { 'INSTALL_RTAIL_NPM':  
    command  => 'npm install -g rtail',
    creates  => "/usr/local/bin/rtail",
   # user     => "${wiremock_user_name}",
   # group    => "${wiremock_group_name}"
  } ->

  file { "CREATE_FOLDER_RTAIL": 
    path => "/opt/rtail",
    ensure => directory,
    owner  => "vagrant",
    group  => "vagrant",
    mode   => 0644
  } ->

#  file { "COPY_INITD_RTAIL_SERVER":
#    path => "/etc/init.d/rtail-server",
#    owner  => root,
#    group  => root,
#    mode   => 755,
#    source => "/vagrant/provision/wso2-stack-srv/puppet/modules/rtail_server/files/rtail-server"
#  } ->

#  service { "ENABLE_SERVICE_RTAIL_SERVER":
#    name   => "rtail-server",
#    ensure => true,
#    enable => true
#  } -> 

  file { "COPY_INITD_RTAIL_SEND_LOGS":
    path => "/etc/init.d/rtail-send-logs",
    owner  => root,
    group  => root,
    mode   => 755,
    source => "/vagrant/provision/wso2-stack-srv/puppet/modules/rtail_sender/files/rtail-send-logs"
  } -> 

  service { "ENABLE_SERVICE_RTAIL_SEND_LOGS":
    name   => "rtail-send-logs",
    ensure => stopped,
    enable => false
  }

}