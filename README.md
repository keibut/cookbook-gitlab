GitLab Cookbook
===============

Chef to install The GitLab.

* GitLab: 6.0.0
* GitLab Shell: 1.7.1
* Ruby: 1.9.3
* Redis: 2.6.13
* Git: 1.8.4
* Nginx: 1.1.19
* PostgreSQL: 9.1.9
* MySQL: 5.5.31 -> no use

## Requirements

* [Berkshelf](http://berkshelf.com/)
* [Vagrant](http://www.vagrantup.com/)

### Vagrant Plugin

* [vagrant-berkshelf](https://github.com/RiotGames/vagrant-berkshelf)
* [vagrant-aws](https://github.com/mitchellh/vagrant-aws)


### Platform:

* CentOS (6.4)


## Attributes

* Package
* User
* GitLab shell
* GitLab shell config
* GitLab hq
* GitLab hq config
* Gems
* Git


## Installation

### Vagrant

#### VirtualBox 

```bash
$ gem install berkshelf
$ vagrant plugin install vagrant-berkshelf
$ git clone git://github.com/ogom/cookbook-gitlab ./gitlab
$ cd ./gitlab/
$ vi ./Vagrantfile 
$ vagrant up
$ vagrant ssh
vagrant$ curl -L https://www.opscode.com/chef/install.sh | sudo bash
vagrant$ exit
$ vagrant provision
```

#### Amazon Web Services

```bash
$ gem install berkshelf
$ vagrant plugin install vagrant-berkshelf
$ vagrant plugin install vagrant-aws
$ vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
$ git clone git://github.com/ogom/cookbook-gitlab ./gitlab
$ cd ./gitlab/
$ cp ./example/Vagrantfile_aws ./Vagrantfile
$ vi ./Vagrantfile
$ vagrant up --provider=aws
$ vagrant ssh
vagrant$ curl -L https://www.opscode.com/chef/install.sh | sudo bash
vagrant$ exit
$ vagrant ssh-config | awk '/HostName/ {print $2}'
$ vi ./Vagrantfile
$ vagrant provision
```

### knife-solo

```bash
$ gem install berkshelf
$ gem install knife-solo
$ knife configure
$ knife solo init ./chef-repo
$ cd ./chef-repo/
$ echo 'cookbook "gitlab", github: "ogom/cookbook-gitlab"' >> ./Berksfile
$ berks install --path ./cookbooks
$ knife solo prepare vagrant@127.0.0.1 -p 2222 -i ~/.vagrant.d/insecure_private_key
$ vi ./nodes/127.0.0.1.json
$ knife solo cook vagrant@127.0.0.1 -p 2222 -i ~/.vagrant.d/insecure_private_key --no-chef-check
```


## Usage

Example of node config.

```json
{
  "postfix": {
    "mail_type": "client",
    "myhostname": "mail.example.com",
    "mydomain": "example.com",
    "myorigin": "mail.example.com",
    "smtp_use_tls": "no"
  },
  "postgresql": {
    "password": {
      "postgres": "psqlpass"
    }
  },
  "gitlab": {
    "host": "example.com",
    "url": "http://example.com/",
    "email_from": "gitlab@example.com",
    "support_email": "support@example.com",
    "database_adapter": "postgresql",
    "database_password": "datapass"
  },
  "run_list":[
    "postfix",
    "gitlab::initial",
    "gitlab::install"
  ]
}
```


### GitLab Update

Add `gitlab::update` to `run_list`.  

```json
{
...
  "run_list":[
    "gitlab::update",
    "gitlab::install"
  ]
}
```

## Done!

`http://localhost/` or your server for your first GitLab login.

```
admin@local.host
5iveL!fe
```

## Links

* [GitLab Installation](https://github.com/gitlabhq/gitlabhq/blob/6.0-stable/doc/install/installation.md)
* [Qiita Document](http://qiita.com/items/6491a268bfc95d0a5be4) (ogom-san's)


## License 

* MIT
