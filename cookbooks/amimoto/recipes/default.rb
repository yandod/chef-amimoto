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

#sed -e "s/\date\.timezone = \"UTC\"/date\.timezone = \"Asia\/Tokyo\"/" etc/php.ini > /etc/php.ini
#cp -Rf etc/php.d/* /etc/php.d/
#cp etc/php-fpm.conf /etc/
#cp -Rf etc/php-fpm.d/* /etc/php-fpm.d/
#rm -Rf /var/log/php-fpm/*
#service php-fpm start; chkconfig php-fpm on
#
#mkdir -p /var/tmp/php/session
#mkdir /var/www/vhosts
#chown -R nginx:nginx /var/tmp/php/session
#chown -R nginx:nginx /var/log/php-fpm
#chown -R nginx:nginx /var/www/vhosts
#
#cp usr/local/bin/wp-setup /usr/local/bin/; chmod +x /usr/local/bin/wp-setup
#cp usr/local/bin/wp-replace-siteurl /usr/local/bin/; chmod +x /usr/local/bin/wp-replace-siteurl
#
#/usr/local/bin/wp-setup default