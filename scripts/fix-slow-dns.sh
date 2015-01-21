#!/bin/bash -eux

if [[ "$PACKER_BUILDER_TYPE" == virtualbox* ]]; then
  ## https://access.redhat.com/site/solutions/58625 (subscription required)
  # add 'single-request-reopen' so it is included when /etc/resolv.conf is generated
  echo 'RES_OPTIONS="single-request-reopen"' >> /etc/sysconfig/network
  service network restart
  echo 'Slow DNS fix applied (single-request-reopen)'

  echo "nameserver 114.114.114.114" > /etc/resolv.conf
  echo "nameserver 8.8.8.8" >> /etc/resolv.conf

  /bin/echo '127.0.0.1   vagrant-centos-6.vagrantup.com' >> /etc/hosts

  echo insecure > /root/.curlrc
  #rpm -ivh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
  #sed -i "s@https@http@g" `grep 'http' -rl /etc/yum.repos.d/`
  #wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo

  # install libyaml
  /usr/bin/curl -L -o /tmp/yaml-0.1.4.tar.gz http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
  cd /tmp/ && tar zxvf yaml-0.1.4.tar.gz > /dev/null 2>&1
  cd yaml-0.1.4 
  ./configure --prefix=/usr/local > /dev/null 2>&1
  make > /dev/null 2>&1
  make install > /dev/null 2>&1
  cd /tmp/ && rm -rf yaml-0.1.4*

  # 设置固定的yum source
  #sed -i "s@enabled=1@enabled=0@g" `grep 'enabled=1' -rl /etc/yum/pluginconf.d/fastestmirror.conf`
  #sed -i "s@#baseurl=@baseurl=@g" `grep '#baseurl=' -rl /etc/yum.repos.d/epel.repo`
  #sed -i "s@mirrorlist=@#mirrorlist=@g" `grep 'mirrorlist=' -rl /etc/yum.repos.d/epel.repo`

  #sed -i "s@mirrorlist=@#mirrorlist=@g" `grep 'mirrorlist=' -rl /etc/yum.repos.d/CentOS-Base.repo`

  #std_baseurl='#baseurl=http://mirror.centos.org/centos/$releasever/os/$basearch/'
  #new_baseurl='baseurl=http://mirrors.aliyun.com/centos/$releasever/os/$basearch/'
  #repo_file='/etc/yum.repos.d/CentOS-Base.repo'
  #sed -i "s@${std_baseurl}@${new_baseurl}@g" `grep '${std_baseurl}' -rl ${repo_file}`

  #设置yum更新源为aliyun
  mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
  wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
  wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
  

else
  echo 'Slow DNS fix not required for this platform, skipping'
fi
