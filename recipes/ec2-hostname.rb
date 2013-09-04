#
# Cookbook Name:: server
# Recipe:: ec2-hostname
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
#

is_aws = node[:cloud] && node[:cloud][:provider] == "ec2"

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