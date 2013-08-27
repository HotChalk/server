#
# Cookbook Name:: server
# Recipe:: default
#
# Copyright 2013, Edify Software Consulting.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe "aws"
include_recipe "apt"

# Default packages to be installed
default_packages = %w{ curl unzip mdadm vim }

default_packages.each { |pkg| package pkg }

users_manage "sysadmin" do
  group_id 2300
  data_bag node[:server][:users][:data_bag]
  action [ :remove, :create ]
end

sudo "sysadmin" do
    user "%sysadmin"
    runas "ALL"
    nopasswd true
end

swap_file "/swap" do
    size node[:server][:swap][:size]
end

directory "/srv" do
  owner "root"
  group "root"
  action :create
end

is_aws = node[:cloud] && node[:cloud][:provider] == "ec2"

if is_aws

    aws = data_bag_item(node[:aws][:databag_name], node[:aws][:databag_entry])

    if node[:server][:data_volume][:raid]
        ebs_devices = (1..node[:server][:data_volume][:disk_count]).collect {|i| "#{node[:server][:data_volume][:ebs_device]}#{i}"}
        system_devices = (1..node[:server][:data_volume][:disk_count]).collect {|i| "#{node[:server][:data_volume][:system_device]}#{i}"}

        # Create the ESB volumes
        ebs_devices.each do |dev|
            aws_ebs_volume "raid devise #{dev}" do
                aws_access_key aws["aws_access_key_id"]
                aws_secret_access_key aws["aws_secret_access_key"]
                size node[:server][:data_volume][:disk_size]
                device dev
                volume_type node[:server][:data_volume][:disk_type]
                piops node[:server][:data_volume][:disk_piops]
                action [:create, :attach]
            end
        end

        # Create the raid device
        mdadm node[:server][:data_volume][:raid_device] do
            devices system_devices
            level node[:server][:data_volume][:raid_level]
            chunk 256
            action [:create, :assemble]
        end

        # Format the raid device
        execute "format data volume" do
            command "mke2fs -t #{node[:server][:data_volume][:filesystem]} #{node[:server][:data_volume][:raid_device]}"
            returns [0, 1]
        end

        # Finally mount and enable the raid device
        mount "/srv" do
            device node[:server][:data_volume][:raid_device]
            fstype node[:server][:data_volume][:filesystem]
            options "defaults,nobootwait,noatime,nodiratime"
            action [:mount, :enable]
        end

        # Update the mdadm configuration
        execute "updating mdamd config file" do
            command "mdadm --detail --scan >> /etc/mdadm/mdadm.conf"
            only_if { File.open("/etc/mdadm/mdadm.conf") {|f| f.grep(/#{node[:server][:data_volume][:raid_device]}/)}.empty? }
        end
    else
        aws_ebs_volume "data_volume" do
            aws_access_key aws["aws_access_key_id"]
            aws_secret_access_key aws["aws_secret_access_key"]
            size node[:server][:data_volume][:disk_size]
            device node[:server][:data_volume][:ebs_device]
            volume_type node[:server][:data_volume][:disk_type]
            piops node[:server][:data_volume][:disk_piops]
            action [:create, :attach]
        end

        execute "format data volume" do
            command "mke2fs -t #{node[:server][:data_volume][:filesystem]} #{node[:server][:data_volume][:system_device]}"
            returns [0, 1]
        end

        mount "/srv" do
            device node[:server][:data_volume][:system_device]
            fstype node[:server][:data_volume][:filesystem]
            options "defaults,nobootwait,noatime,nodiratime"
            action [:mount, :enable]
        end
    end
end

%w{ /srv/config /srv/logs /srv/data /srv/backups }.each do |dir|
    directory dir do
        owner "root"
        group "root"
        mode 00755
    end
end

if is_aws
  directory "/usr/local/ec2" do
    owner "root"
    group "root"
    mode 00755
  end

  template "/usr/local/ec2/ec2-set-hostname" do
    source "ec2-set-hostname.erb"
    owner "root"
    group "root"
    mode 00755
  end

  execute "set hostname" do
    command "/usr/local/ec2/ec2-set-hostname"
  end

  cookbook_file "/etc/rc.local" do
    source "rc.local"
    owner "root"
    group "root"
    mode 00755
  end
end
