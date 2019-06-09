#!/bin/env sh

rootfs-expand

if [ ! -f /etc/yum.repos.d/epel.repo ]; then
    cat <<EOF > /etc/yum.repos.d/epel.repo
[epel]
name=Epel for arm
baseurl=https://armv7.dev.centos.org/repodir/epel-pass-1/
enabled=1
gpgcheck=0
EOF
fi

if [ ! -f /etc/yum.repos.d/salt.repo ]; then
    cat <<EOF > /etc/yum.repos.d/salt.repo
[saltstack-repo]
name=SaltStack
baseurl=https://repo.saltstack.com/yum/redhat/\$releasever/x86_64/latest
enabled=1
gpgcheck=0
EOF
fi

yum update -y
yum install -y git salt-minion vim

mkdir -p /srv/salt

#curl https://megalith.rocks/files/bol_spaces_summit_2019.tar.gz | tar xvz -C /srv/salt
git clone git@github.com:jeroen92/bol_spaces_summit_2019.git /srv/salt

salt-call --local state.apply

echo 'Finito, masekind! Lekker!'

