#
# Cookbook Name:: server
# Recipe:: users
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

users_manage "sysadmin" do
  group_id 2300
  data_bag node[:server][:users][:data_bag]
  action [ :remove, :create ]
end

sudo "sysadmin" do
    user "%sysadmins"
    runas "ALL"
    nopasswd true
end
