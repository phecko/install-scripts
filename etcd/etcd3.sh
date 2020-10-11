#!/bin/bash

ETCD_VERSION=${ETCD_VERSION:-v3.3.1}

if [ ! -f "etcd-${ETCD_VERSION}-linux-amd64.tar.gz" ]; then
    curl -L https://github.com/coreos/etcd/releases/download/$ETCD_VERSION/etcd-$ETCD_VERSION-linux-amd64.tar.gz -o etcd-$ETCD_VERSION-linux-amd64.tar.gz
fi 

tar xzvf etcd-$ETCD_VERSION-linux-amd64.tar.gz
rm etcd-$ETCD_VERSION-linux-amd64.tar.gz

cd etcd-$ETCD_VERSION-linux-amd64
sudo cp etcd /usr/local/bin/
sudo cp etcdctl /usr/local/bin/

rm -rf etcd-$ETCD_VERSION-linux-amd64

etcdctl --version

echo -e "\033[32m Start set etcd config \033[0m"

sudo mkdir -p /var/lib/etcd/
sudo mkdir /etc/etcd
sudo groupadd --system etcd
sudo useradd -s /sbin/nologin --system -g etcd etcd

sudo chown -R etcd:etcd /var/lib/etcd/

sudo cat >>/etc/systemd/system/etcd.service<<EOF
[Unit]
Description=etcd key-value store
Documentation=https://github.com/etcd-io/etcd
After=network.target

[Service]
User=etcd
Type=notify
Environment=ETCD_DATA_DIR=/var/lib/etcd
Environment=ETCD_NAME=%m
ExecStart=/usr/local/bin/etcd
Restart=always
RestartSec=10s
LimitNOFILE=40000

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl  daemon-reload
sudo systemctl  start etcd.service

sudo systemctl  status etcd.service