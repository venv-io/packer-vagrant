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
  rpm -ivh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
  sed -i "s@https@http@g" `grep 'http' -rl /etc/yum.repos.d/`

  # install libyaml
  /usr/bin/curl -L -o /tmp/yaml-0.1.4.tar.gz http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
  cd /tmp/ && tar zxvf yaml-0.1.4.tar.gz && cd yaml-0.1.4 
  ./configure --prefix=/usr/local && make && make install
  cd /tmp/ && rm -rf yaml-0.1.4*

else
  echo 'Slow DNS fix not required for this platform, skipping'
fi
