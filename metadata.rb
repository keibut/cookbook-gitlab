name             'gitlab6'
maintainer       'keibut'
maintainer_email 'kei.hino+github@gmail.com'
license          'MIT'
description      'Installs/Configures GitLab6'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.6.0'

recipe "gitlab::initial", "Setting the initial"
recipe "gitlab::install", "Installation"

#%w{redisio ruby_build postgresql mysql database postfix yum}.each do |dep|
%w{redisio ruby_build postgresql database postfix yum}.each do |dep|
  depends dep
end

#%w{debian ubuntu centos}.each do |os|
%w{centos}.each do |os|
  supports os
end
