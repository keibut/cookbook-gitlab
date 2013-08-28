#
# Cookbook Name:: gitlab
# Recipe:: gitlab
#

gitlab = node['gitlab']

# 6. GitLab
## Clone the Source
git gitlab['path'] do
  repository gitlab['repository']
  revision gitlab['revision']
  user gitlab['user']
  group gitlab['group']
  action :sync
end

## Configure it
### Copy the example GitLab config
template File.join(gitlab['path'], 'config', 'gitlab.yml') do
  source "gitlab.yml.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :host => gitlab['host'],
    :port => gitlab['port'],
    :user => gitlab['user'],
    :email_from => gitlab['email_from'],
    :support_email => gitlab['support_email'],
    :satellites_path => gitlab['satellites_path'],
    :repos_path => gitlab['repos_path'],
    :shell_path => gitlab['shell_path']
  })
end

### Make sure GitLab can write to the log/ and tmp/ directories
%w{log tmp}.each do |path|
  directory File.join(gitlab['path'], path) do
    owner gitlab['user']
    group gitlab['group']
    mode 0755 
  end
end

### Create directory for satellites
directory gitlab['satellites_path'] do
  owner gitlab['user']
  group gitlab['group']
end

### Create directories for sockets/pids and make sure GitLab can write to them
%w{tmp/pids tmp/sockets}.each do |path|
  directory File.join(gitlab['path'], path) do
    owner gitlab['user']
    group gitlab['group']
    mode 0755 
  end
end

### Create public/uploads directory otherwise backup will fail
%w{public/uploads}.each do |path|
  directory File.join(gitlab['path'], path) do
    owner gitlab['user']
    group gitlab['group']
    mode 0755
  end
end

### Copy the example Puma config
template File.join(gitlab['path'], "config", "unicorn.rb") do
  source "unicorn.rb.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :path => gitlab['path'],
    :env => gitlab['env']
  })
end

### Configure Git global settings for git user, useful when editing via web
bash "git config" do
  code <<-EOS
    git config --global user.name "GitLab"
    git config --global user.email "gitlab@#{gitlab['host']}"
  EOS
  user gitlab['user']
  group gitlab['group']
  environment('HOME' => gitlab['home'])
end

## Configure GitLab DB settings
template File.join(gitlab['path'], "config", "database.yml") do
  source "database.yml.#{gitlab['database_adapter']}.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :user => gitlab['user'],
    :password => gitlab['database_password']
  })
end

## Install Gems
gem_package "charlock_holmes" do
  version "0.6.9.4"
  options "--no-ri --no-rdoc"
end

template File.join(gitlab['home'], ".gemrc") do
  source "gemrc.erb"
  user gitlab['user']
  group gitlab['group']
  notifies :run, "execute[bundle install]", :immediately
end

### without
bundle_without = []
case gitlab['database_adapter']
when 'mysql'
  bundle_without << 'postgres'
when 'postgresql'
  bundle_without << 'mysql'
end

case gitlab['env']
when 'production'
  bundle_without << 'development'
  bundle_without << 'test'
else
  bundle_without << 'production'
end

execute "bundle install" do
  command "#{gitlab['bundle_install']} --without #{bundle_without.join(" ")}"
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  action :nothing
end

### db:setup
execute "rake db:setup" do
  command "bundle exec rake db:setup RAILS_ENV=#{gitlab['env']}"
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  not_if {File.exists?(File.join(gitlab['home'], ".gitlab_setup"))}
end

file File.join(gitlab['home'], ".gitlab_setup") do
  owner gitlab['user']
  group gitlab['group']
  action :create
end

### db:migrate
execute "rake db:migrate" do
  command "bundle exec rake db:migrate RAILS_ENV=#{gitlab['env']}"
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  not_if {File.exists?(File.join(gitlab['home'], ".gitlab_migrate"))}
end

file File.join(gitlab['home'], ".gitlab_migrate") do
  owner gitlab['user']
  group gitlab['group']
  action :create
end

### db:seed_fu
execute "rake db:seed_fu" do
  command "bundle exec rake db:seed_fu RAILS_ENV=#{gitlab['env']}"
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  not_if {File.exists?(File.join(gitlab['home'], ".gitlab_seed"))}
end

file File.join(gitlab['home'], ".gitlab_seed") do
  owner gitlab['user']
  group gitlab['group']
  action :create
end

## Install Init Script
template "/etc/init.d/gitlab" do
  source "initd.erb"
  mode 0755
  variables({
    :path => gitlab['path'],
    :user => gitlab['user'],
    :env => gitlab['env']
  })
end

## Start Your GitLab Instance
service "gitlab" do
  supports :start => true, :stop => true, :restart => true, :status => true
  action :enable
end

file File.join(gitlab['home'], ".gitlab_start") do
  owner gitlab['user']
  group gitlab['group']
  action :create_if_missing
  notifies :start, "service[gitlab]"
end
