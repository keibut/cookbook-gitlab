# Git
default['gitlab']['git']['prefix'] = "/usr/local"
default['gitlab']['git']['version'] = "1.8.4"
default['gitlab']['git']['url'] = "https://github.com/git/git/archive/v#{node['gitlab']['git']['version']}.zip"
default['gitlab']['git']['http_proxy'] = nil
default['gitlab']['git']['https_proxy'] = nil

if platform_family?("rhel")
  packages = %w{unzip expat-devel gettext-devel libcurl-devel openssl-devel perl-ExtUtils-MakeMaker zlib-devel}
else
  packages = %w{unzip build-essential libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev}  
end

default['gitlab']['git']['packages'] = packages
