#!/bin/bash

# System updates
echo 'libc6 libraries/restart-without-asking boolean true' | sudo debconf-set-selections
export DEBIAN_FRONTEND=noninteractive
echo "Updating apt repos..."
apt-get -y remove grub-pc
apt-get -y install grub-pc
update-grub
apt-get update > /dev/null 2>&1

echo "Updating system..."
apt-get -y upgrade > /dev/null 2>&1

echo "Installing additional software..."
apt-get -y install git jq openjdk-8-jdk python3 python3-pip npm > /dev/null 2>&1

echo "Adding AWS config..."
mkdir -p /root/.aws
sudo bash -c "cat >/root/.aws/config" <<EOF
[default]
aws_access_key_id=${AWS_ACCESS_KEY}
aws_secret_access_key=${AWS_SECRET_KEY}
EOF
sudo bash -c "cat >/root/.aws/credentials" <<EOF
[default]
aws_access_key_id=${AWS_ACCESS_KEY}
aws_secret_access_key=${AWS_SECRET_KEY}
region=${AWS_REGION}
EOF

echo "Installing AWS CLI..."
pip3 install botocore
pip3 install boto3
pip3 install awscli

echo "Get public IP..."
export PUBLIC_IP=`curl http://169.254.169.254/latest/meta-data/public-ipv4`

mkdir -p /opt/api/
aws s3 cp s3://hc-downloadable-assets/javaperks-customer-api-0.2.6.jar /opt/api/javaperks-customer-api-0.2.6.jar


sudo bash -c "cat >/opt/api/config.yml" <<EOF
logging:
  level: INFO
  loggers:
    com.javaperks.api: DEBUG
server:
  applicationConnectors:
  - type: http
    port: 5822
  adminConnectors:
  - type: http
    port: 9001
vaultAddress: "http://localhost:8200"
vaultToken: "root"
EOF


echo "All done!"
