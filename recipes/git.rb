#
# Cookbook Name:: gitlab
# Recipe:: git
#

git = node['gitlab']['git']

git['packages'].each do |pkg|
  package pkg
end

remote_file "#{Chef::Config['file_cache_path']}/git-#{git['version']}.zip" do
  source git['url']
  mode 00644
  not_if "test -f #{Chef::Config['file_cache_path']}/git-#{git['version']}.zip"
end

execute "Extracting and Building Git #{git['version']} from Source" do
  command <<-EOS
    unzip -q git-#{git['version']}.zip
    cd git-#{git['version']} && make configure && ./configure --prefix=#{git['prefix']} && make all && make install
  EOS
  cwd Chef::Config['file_cache_path']
  creates "#{git['prefix']}/bin/git"
  not_if "git --version | grep #{git['version']}"
end

execute "Proxy Setting for git" do
  command <<-EOS
    git config --global http.proxy #{git['http_proxy']}
    git config --global https.proxy #{git['https_proxy']}
  EOS
  action :nothing
end

