link "/etc/localtime" do
    to "/usr/share/zoneinfo/Asia/Tokyo"
end

#cp etc/motd.jp /etc/motd
#
#yum -y update
%w{zip unzip wget iptables}.each do |package_name|
  package package_name do
    action [:install,:upgrade]
  end
end

template "/etc/sysconfig/iptables" do
  source "sysconfig.iptables.erb"
end

service "iptables" do
  action [:enable, :restart]
end

include_recipe "yum::epel"

package "denyhosts" do
  action [:install,:upgrade]
end

service "denyhosts" do
  action [:enable, :restart]
end

package "memcached" do
  action [:install,:upgrade]
end

service "memcached" do
  action [:enable, :restart]
end

include_recipe "yum::remi"
%w{php php-cli php-devel php-mbstring php-gd php-pear php-xml php-fpm php-pecl-apc php-pecl-memcache}.each do |package_name|
  package package_name do
    action [:install, :upgrade]
  end
end

service "httpd" do
  action [:stop, :disable]
end

remote_file "#{Chef::Config[:file_cache_path]}/nginx-release-centos-6-0.el6.ngx.noarch.rpm" do
  source "http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm"
end
package "nginx-release" do
  source "#{Chef::Config[:file_cache_path]}/nginx-release-centos-6-0.el6.ngx.noarch.rpm"
  action :install
  provider Chef::Provider::Package::Rpm
end

package "nginx" do
  action [:install, :upgrade]
end

service "nginx" do
  action [:enable, :restart]
end

cookbook_file "#{Chef::Config[:file_cache_path]}/percona-release-0.0-1.x86_64.rpm" do
  source "percona-release-0.0-1.x86_64.rpm"
end
package "percona-release" do
  source "#{Chef::Config[:file_cache_path]}/percona-release-0.0-1.x86_64.rpm"
  action :install
  provider Chef::Provider::Package::Rpm
end

# Percona-Server-shared-compat is conflicting
%w{Percona-Server-server-55 Percona-Server-client-55}.each do |package_name|
  package package_name do
    action [:install, :upgrade]
  end
end

service "mysql" do
  action [:enable, :restart]
end

%w{php-mysqlnd php-pdo phpMyAdmin}.each do |package_name|
  package package_name do
    action [:install, :upgrade]
  end
end

template "/etc/php.ini" do
  variables(
     :timezone => "Asia/Tokyo"
   )
  source "php.ini.erb"
end

%w{apc.ini memcache.ini}.each do |file_name|
  template "/etc/php.d/" + file_name do
    source file_name + ".erb"
  end
end

template "/etc/php-fpm.conf" do
  source "php-fpm.conf.erb"
end

template "/etc/php-fpm.d/www.conf" do
  source "www.conf.erb"
end

service "php-fpm" do
  action [:enable, :restart]
end

%w{/var/tmp/php/session /var/www/vhosts /var/log/php-fpm}.each do |dir_name|
  directory dir_name do
    owner "nginx"
    group "nginx"
    mode 00644
    recursive true
    action :create
  end
end

#cp usr/local/bin/wp-setup /usr/local/bin/; chmod +x /usr/local/bin/wp-setup
#cp usr/local/bin/wp-replace-siteurl /usr/local/bin/; chmod +x /usr/local/bin/wp-replace-siteurl
#
#/usr/local/bin/wp-setup default