#!/bin/bash
# update and upgrade packages
apt-get update && apt-get upgrade -y
# install dependencies
apt-get install -y unzip curl wget jq
# grab consul 
wget https://releases.hashicorp.com/consul/1.9.5/consul_1.9.5_linux_amd64.zip
# unzip consul
unzip consul_1.9.5_linux_amd64.zip -d /usr/bin/
# remove consul zip
rm -rf ./consul_1.4.4_linux_amd64.zip
# create service file
cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description=Consul
Documentation=https://www.consul.io/
[Service]
ExecStart=/usr/bin/consul agent -server -ui -data-dir=/temp/consul -bootstrap-expect=1 -node=vault -bind=0.0.0.0 -config-dir=/etc/consul.d/
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF
# create consul directory
mkdir /etc/consul.d
# create ui config
cat << EOF > /etc/consul.d/ui.json
{
  "addresses": {
    "http": "0.0.0.0"
  }
}
EOF
# reload daemon
systemctl daemon-reload
# start consul service
systemctl start consul
# set consul to start on restart
systemctl enable consul
# install certbot
apt install -y certbot
# make vault directory
mkdir /etc/vault
# make certs directory
mkdir /etc/vault/certs
# run certbot update domain address and brackets removed to be route53 created in terraform 
export VAULT_DOMAIN_ADDRESS=vault.{{example.com}}
echo "export VAULT_DOMAIN_ADDRESS=vault.{{example.com}}" >> ~./bashrc
certbot certonly --standalone -d $VAULT_DOMAIN_ADDRESS --non-interactive --agree-tos -m support@strongdm.com
wget https://releases.hashicorp.com/vault/1.7.2/vault_1.7.2_linux_amd64.zip
# unzip vault
unzip vault_1.7.2_linux_amd64.zip -d /usr/bin/
#remove vault zip
rm -rf ./vault_1.7.2_linux_amd64.zip
# create vault config
cat << EOF > /etc/vault/config.hcl
storage "consul" {
  address = "0.0.0.0:8500"
  path = "vault/"
}
listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 0
  tls_cert_file = "/etc/letsencrypt/live/$VAULT_DOMAIN_ADDRESS/fullchain.pem"
  tls_key_file = "/etc/letsencrypt/live/$VAULT_DOMAIN_ADDRESS/privkey.pem"
}
ui = true
EOF
# create vault service
cat << EOF > /etc/systemd/system/vault.service
[Unit]
Description=Vault
Documentation=https://www.vault.io/
[Service]
ExecStart=/usr/bin/vault server -config=/etc/vault/config.hcl
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF
# reload daemon
systemctl daemon-reload
# export vault address variable
export VAULT_ADDR="https://$VAULT_DOMAIN_ADDRESS:8200"
# set vault address to reload on reboot
echo "export VAULT_ADDR=https://$VAULT_DOMAIN_ADDRESS:8200" >> ~/.bashrc
# enable vault autocomplete
vault -autocomplete-install
complete -C /usr/bin/vault vault
#start vault
systemctl start vault
# enable vault to start on restart
systemctl enable vault
# initialize vault and save file
vault operator init | tee -a vault-key.txt