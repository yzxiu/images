# go
yum install -y wget vim

GO_VERSION=1.19.4

FILE_NAME="go$GO_VERSION.linux-amd64.tar.gz"
GO_URL="https://go.dev/dl/$FILE_NAME"

rm -rf ~/$FILE_NAME
wget $GO_URL -O ~/$FILE_NAME >/dev/null

rm -rf /usr/local/go
tar -zxvf ~/$FILE_NAME -C /usr/local/ >/dev/null

rm -rf /usr/bin/go
ln -s /usr/local/go/bin/go /usr/bin

rm -rf ~/$FILE_NAME

go version

# xcaddy
go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

# caddy build
~/go/bin/xcaddy build --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive --with github.com/caddy-dns/alidns

# rm -rf ~/caddy
# wget https://raw.githubusercontent.com/yzxiu/images/master/caddy -P ~ >/dev/null
chmod +x ~/caddy

cp ~/caddy /usr/bin/
setcap cap_net_bind_service=+ep /usr/bin/caddy

# vim /etc/caddy/Caddyfile
mkdir /etc/caddy
cat >/etc/caddy/Caddyfile <<EOF
:443, *.********.com 
tls {
  dns alidns {
    access_key_id "***************"
    access_key_secret "************************"
  }
}
route {
  forward_proxy {
    basic_auth *************** ************************
    hide_ip
    hide_via
    probe_resistance
  }
}
EOF

# /etc/systemd/system/naive.service
# vim /etc/systemd/system/naive.service
cat >/etc/systemd/system/naive.service <<EOF
[Unit]
Description=Caddy
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target

[Service]
Type=notify
User=root
Group=root
ExecStart=/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

# systemctl
systemctl start naive
systemctl status naive
