#
# Cookbook Name:: mongo
# Recipe:: default
#
# Copyright 2012, Skystack Ltd
#
# All rights reserved - Do Not Redistribute
#

case node['platform']
when "debian", "ubuntu"
  # Adds the repo: http://www.mongodb.org/display/DOCS/Ubuntu+and+Debian+packages
  execute "apt-get update" do
    action :nothing
  end

  apt_repository "10gen" do
    uri "http://downloads-distro.mongodb.org/repo/debian-sysvinit"
    distribution "dist"
    components ["10gen"]
    keyserver "keyserver.ubuntu.com"
    key "7F0CEB10"
    action :add
    notifies :run, "execute[apt-get update]", :immediately
  end

  package "mongodb" do
    package_name "mongodb-10gen"
  end
else
    Chef::Log.warn("Adding the #{node['platform']} 10gen repository is not yet not supported by this cookbook")
end

template "/etc/mongodb.conf" do
    source "mongodb.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :log_path       => node['mongo']['log_path'],
      :db_path        => node['mongo']['db_path']
    )
end

directory "#{node['mongo']['log_path']}" do
    owner "root"
    group "root"
    mode "0755"
    action :create
    recursive true
end

service "mongodb" do
  provider Chef::Provider::Service::Init
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

service "mongodb" do 
  action :start
end