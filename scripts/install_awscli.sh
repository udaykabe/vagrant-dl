#!/usr/bin/env sh

#########################################
#  AWSCLI INSTALLATON SCRIPT            #
#########################################

echo "===== Setting up AWS CLI configuration in $HOME as `whoami` ====="
if [ ! -d $HOME/.aws ]
  then mkdir $HOME/.aws
fi

cat > $HOME/.aws/config <<EOF
[default]
region = us-east-1
EOF

cat > $HOME/.aws/credentials <<EOF
[default]
aws_access_key_id = $1
aws_secret_access_key = $2
EOF

echo "===== Installing the AWS CLI as `whoami` ====="
pip install --upgrade awscli
echo "AWS CLI executable installed in: `which aws`"
