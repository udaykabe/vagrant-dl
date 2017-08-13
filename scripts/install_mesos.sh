#!/usr/bin/env sh

#########################################
#  MESOS MARATHON INSTALLATON SCRIPT    #
#########################################

# Provide an IP address as the first argument

# visit https://open.mesosphere.com/getting-started/install/
echo ">>>  INSTALLING MESOS... as `whoami`"

DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]') # => ubuntu
CODENAME=$(lsb_release -cs) # => xenial

readonly IP_ADDRESS = $1

readonly MESOS_VERSION=1.2.0-2.0.6 # was 1.0.0-2.0.89
readonly MARATHON_VERSION=1.4.3-1.0.649 #was 1.1.2-1.0.482
readonly ZOOKEEPER_VERSION=3.4.8-1

echo ">>> IP Address is: $IP_ADDRESS"
  
# Import Mesosphere GPG key in order to verify package signatures
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF
# Add the repository
echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" | \
  tee /etc/apt/sources.list.d/mesosphere.list

apt-get update -q --fix-missing

# On trusty, the marathon package needs java 8, otherwise it fails to install
if [ $CODENAME = "trusty" ]
then
  add-apt-repository ppa:openjdk-r/ppa -y
  apt-get update -y
  apt-get install -y --no-install-recommends openjdk-8-jdk
  update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
fi

# Update package index
apt-get update -y
apt-get -y install mesos=${MESOS_VERSION}.ubuntu1404
apt-get -y install marathon=${MARATHON_VERSION}.ubuntu1404

echo "1" > /etc/zookeeper/conf/myid
cat > /etc/zookeeper/conf/zoo.cfg <<EOF
server.1=$IP_ADDRESS:2888:3888
EOF

cat > /etc/mesos/zk <<EOF
zk://$IP_ADDRESS:2181/mesos
EOF

cat > /etc/mesos-master/quorum <<EOF
1
EOF

# Cluster configuration
mkdir -p /etc/marathon
cat >> /etc/marathon/clusters.json <<EOF
[{
  "name": "devcluster",
  "zk": "$IP_ADDRESS",
  "scheduler_zk_path": "/aurora/scheduler",
  "auth_mechanism": "UNAUTHENTICATED",
  "slave_run_directory": "latest",
  "slave_root": "/var/lib/mesos"
}]
EOF

# Ssh configuration
cat >> /etc/ssh/ssh_config <<EOF
# Allow local ssh w/out strict host checking
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF

# Start services
if [ $CODENAME = "trusty" ]
then
  echo "Running on trusty"
  echo "Starting Zookeeper..."
  service zookeeper restart
  echo "Starting Mesos master..."
  service mesos-master start
  echo "Starting Mesos slave..."
  service mesos-slave start
  echo "Starting Marathon..."
  service marathon start
elif [ $CODENAME = "xenial" ]
then
  echo "Running on xenial"
  echo "Restarting Zookeeper..."
  systemctl restart zookeeper
  echo "Restarting Mesos master..."
  systemctl start mesos-master
  echo "Restarting Mesos slave..."
  systemctl start mesos-slave
  echo "Starting Marathon..."
  systemctl start marathon
fi

# Configure netrc
cat > /home/vagrant/.netrc <<EOF
machine $(hostname -f)
login aurora
password secret
EOF

chown -R vagrant:vagrant /home/vagrant/.netrc
