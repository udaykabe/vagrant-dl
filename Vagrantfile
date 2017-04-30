# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

#################################################
#  FIX spurious "stdin: is not a tty" messages  #
#################################################
$fix_stdin_is_not_tty_error = <<SCRIPT
  # Repair "==>defualt: stdin: is not a tty" message
  sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile
SCRIPT

#################################################
#  Install Oracle Java 8 JDK                    #
#################################################
$install_oracle_jdk8 = <<SCRIPT
  add-apt-repository ppa:webupd8team/java
  apt-get update
  # Auto accept license
  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | /usr/bin/debconf-set-selections
  apt-get install -y oracle-java8-installer
SCRIPT

#################################################
#  Install Open Source Confluent Platform 3.2   #
#################################################
$install_confluent_platform = <<SCRIPT
  wget -qO - http://packages.confluent.io/deb/3.2/archive.key | sudo apt-key add -
  add-apt-repository "deb [arch=amd64] http://packages.confluent.io/deb/3.2 stable main"
  apt-get update
  # http://docs.confluent.io/3.2.0/installation.html#available-packages
  apt-get install -y confluent-platform-oss-2.11
SCRIPT

module OS
  def OS.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
   (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
    !OS.windows?
  end

  def OS.linux?
    OS.unix? and not OS.mac?
  end
end

# Functions to check determine provider
module PROVIDER
  # Microsoft Azure
  def PROVIDER.isAzure?
    isAzure = false
    ARGV.each do |a|
      if a.include?('--provider=')
        provider = a[11, a.length]
        isAzure = (0 == provider.casecmp("azure"))
      end
    end
    isAzure
  end

  # Amazon Web Services (AWS)
  def PROVIDER.isAWS?
    isAWS = false
    ARGV.each do |a|
      if a.include?('--provider=')
        provider = a[11, a.length]
        isAWS = (0 == provider.casecmp("aws"))
      end
    end
    isAWS
  end
end

# Use standard AWS plugin if not using spot instances
required_plugins = %w(vagrant-winnfsd vagrant-azure vagrant-aws)

required_plugins.each do |plugin|
  need_restart = false
  unless Vagrant.has_plugin? plugin
    system "vagrant plugin install #{plugin}"
    need_restart = true
  end
  exec "vagrant #{ARGV.join(' ')}" if need_restart
end

CLUSTER_CONFIG = File.expand_path('config/cluster.yml')
if not File.exist?(CLUSTER_CONFIG)
  raise Vagrant::Errors::VagrantError.new, "Please create cluster.yml for configuration info"
end

cluster = YAML.load_file(CLUSTER_CONFIG)
machines = cluster['machines']
vb_config = machines['vb']
aws_config = machines['aws']
azure_config = machines['azure']

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"  # default box for vm
  #config.ssh.forward_agent = true
  config.vm.synced_folder Dir.getwd, "/vagrant", nfs: true

  config.vm.define "devcluster" do |dockerhost|
    dockerhost.vm.hostname = "dockerhost.local"  # set hostname in /etc/hosts
  
    dockerhost.vm.provision :shell, inline: $fix_stdin_is_not_tty_error

    # Virtualbox  
    dockerhost.vm.provider "virtualbox" do |vb, override|
      override.vm.network :private_network, ip: "192.168.33.8"
      override.vm.synced_folder Dir.getwd, "/vagrant", nfs: true

      vb.name = File.basename(Dir.getwd) + "-docker-vm"
      vb.memory = vb_config['memory']
      vb.cpus = vb_config['cpus']

      # force the VirtualBox NAT engine to intercept DNS requests and forward them to host's resolver
      # equivalent to VBoxManage modifyvm "VM name" --natdnshostresolver1 on
      #vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]

      # tell the NAT engine to act as DNS proxy
      # equivalent to VBoxManage modifyvm "VM name" --natdnsproxy1 on
      #vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    
      override.vm.provision "ansible_local" do |ansible|
        ansible.install = true
        ansible.playbook = "ansible/site.yml"
        ansible.inventory_path = "ansible/inventory"
        ansible.limit = "all" # or only "nodes" group, etc.
        #ansible.tmp_path = "/tmp/vagrant-ansible"
        ansible.extra_vars = { ansible_ssh_user: 'vagrant' }
        #ansible.sudo = true
        #ansible.verbose = true # true or 'vv' or 'vvv' or 'vvvv' or 'vvvvv' increases verbosity
      end

      # Below for testing only
      # AWS authentication info
      aws_access_key_id = ENV['AWS_ACCESS_KEY_ID'] || "ABCDEF0123456789ABCD"
      aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY'] || "abcdef0123456/789ABCD/EF0123456789abcdef"
  
      override.vm.provision "shell" do |s|
        s.path = "scripts/install_awscli.sh"
        s.args   = ["#{aws_access_key_id}", "#{aws_secret_access_key}"]
      end
    end

    # Azure  
    dockerhost.vm.provider :azure do |azure, override|
      #override.vm.boot_timeout=600 # For unreliable internet connections
  
      override.vm.box = 'azuredummybox'
      override.vm.box_url = 'https://github.com/msopentech/vagrant-azure/raw/master/dummy.box'
  
      if OS.windows?
        # !!!--- The use of type 'rsync' assumes that we are running in Cygwin or mingw ---!!!   
        override.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".gitignore", ".project"]
      end
  
      override.ssh.username = azure_config['user'] # assigned below
      # Password is not needed when using private key
      #override.ssh.password = '' # assigned below
  
      # ---------------------------------
      # Mandatory Settings
      # ---------------------------------
      azure.mgmt_certificate = File.expand_path('~/.ssh/mgmt_cert.pfx') # Use for accessing Azure API
      azure.mgmt_endpoint = 'https://management.core.windows.net'
      azure.subscription_id = ENV['AZURE_SUBSCRIPTION_ID'] || 'vvvvvvvv-wwww-xxxx-yyyy-zzzzzzzzzzzz'
      #azure.tenant_id =  ENV['AZURE_TENANT_ID'] || 'vvvvvvvv-wwww-xxxx-yyyy-zzzzzzzzzzzz' # Active Directory Tenant ID
      #azure.client_id = ENV['AZURE_CLIENT_ID'] # Active Directory Client ID
      #azure.client_secret = ENV['AZURE_CLIENT_SECRET'] # Active Directory application client secret
      azure.vm_name = 'ExolyteDevOps' # max 15 characters. contains letters, number and hyphens. can start with letters and can end with letters and numbers
        # Ubuntu Trusty64 14.04 LTS
      #azure.vm_image = 'b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04-LTS-amd64-server-20140724-en-us-30GB'
      #azure.vm_image = 'b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04_5-LTS-amd64-server-20160919-en-us-30GB'
        # Ubuntu Xenial64 16.04
      azure.vm_image = 'b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-16_04-LTS-amd64-server-20160922-en-us-30GB'
        # CoreOS Beta and Stable Releases (as of 10/3/2016)
      #azure.vm_image = '2b171e93f07c4903bcad35bda10acf22__CoreOS-Beta-1153.4.0'
      #azure.vm_image = '2b171e93f07c4903bcad35bda10acf22__CoreOS-Stable-1122.2.0'
  
      azure.vm_user = azure_config['user'] # defaults to 'vagrant' if not provided
      #azure.vm_password = 'password' # min 8 characters. should contain a lower case letter, an uppercase letter, a number and a special character
  
      azure.storage_acct_name = 'mystorageaccountname' # optional. A new one will be generated if not provided.
      azure.cloud_service_name = 'mycloudservice' # same as vm_name. leave blank to auto-generate
      #azure.deployment_name = '' # defaults to cloud_service_name
  
      # Provide the following values if creating a *Nix VM
      azure.ssh_port = '22'
      azure.private_key_file = File.expand_path('~/.ssh/id_rsa')
  
      # Azure VM sizes are specified as one of the following:
        # "ExtraSmall", "Small", "Medium", "Large", "ExtraLarge",
        # "A5", "A6", "A7", "A8", "A9", "A10", "A11",
        # "Basic_A0", "Basic_A1", "Basic_A2", "Basic_A3", "Basic_A4",
        # "Standard_D1", "Standard_D2", "Standard_D3", "Standard_D4",
        # "Standard_D11", "Standard_D12", "Standard_D13", "Standard_D14",
        # "Standard_D1_v2", "Standard_D2_v2", "Standard_D3_v2", "Standard_D4_v2", "Standard_D5_v2"
        # "Standard_D11_v2", "Standard_D12_v2", "Standard_D13_v2", "Standard_D14_v2", "Standard_D15_v2"
        # "Standard_DS1", "Standard_DS2", "Standard_DS3", "Standard_DS4",
        # "Standard_DS11", "Standard_DS12", "Standard_DS13", "Standard_DS14",
        # "Standard_G1", "Standard_G2", "Standard_G3", "Standard_G4", "Standard_G55".
        # The default setting is "Small" which is A1 (1 coreva, 1.75G)
      azure.vm_size = 'Standard_D1_v2' # D2v2 2 cores 7GB has more power than D2
      azure.vm_location = 'Central US' # East US, Central US, North Central US, South Central US, West US, etc.
      #azure.vm_virtual_network_name = '' # The name of a virtual network to connect to
  
      # Open port(s) -- HTTP, HTTPS, Tomcat, etc.
      azure.tcp_endpoints = '80,443,8080,8181,9090'
  
  
      # Add appropriate user to group docker  
      override.vm.provision :shell, inline: <<-SHELL
        echo "Exolyte ====> Adding user #{azure_config['user']} to group docker"
        usermod -aG docker #{azure_config['user']}
      SHELL
    end

    # AWS
    # Manually install vagrant-aws from nabeken for spot instances
    # See this gist: https://gist.github.com/ozzyjohnson/d62b0c8183f0d4d7448e
    dockerhost.vm.provider :aws do |aws, override|
      override.vm.box = "aws-dummy"
      override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
  
      override.ssh.private_key_path = File.expand_path('~/.ssh/id_rsa')
      override.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".gitignore", ".project"]
  
      # t1.micro,   1vcpu, variable ECU, .615GiB, EBS Only, $0.02/hour, $0.0041/hour
      # t2.micro,   1vcpu, variable ECU, 1GiB, EBS Only, $0.012/hour
      # t2.large,   2vcpu, variable ECU, 8GiB, EBS Only, $0.094/hour
      # t2.xlarge,  4vcpu, variable ECU, 16GiB, EBS Only, $0.188/hour
      # t2.2xlarge, 8vcpu, variable ECU, 32GiB, EBS Only, $0.376/hour
      # m4.large,   2vcpu, 6.5 ECU, 8GiB, EBS Only, $0.108/hour, $0.0268/hour
      # m4.xlarge,  4vcpu, 13 ECU, 16GiB, EBS Only, $0.215/hour, $0.0664/hour
      # m4.2xlarge, 8vcpu, 26 ECU, 32GiB, EBS Only, $0.431/hour, $0.0718/hour
      # p2.xlarge,  4vcpu, 12 ECU, 61GiB, EBS Only, $0.9/hour, $0.1343/hour -- machine learning
      # p2.8xlarge, 32vcpu, 94 ECU, 488GiB, EBS Only, $7.20/hour, $0.879/hour
      # r3.large,   2vcpu, 6.5 ECU, 15GiB, 1 x 32 SSD, $0.166/hour, $0.0316/hour   -- bootstrap and agent 60GB needed
      # r3.xlarge,  4vcpu,  13 ECU, 30.5GiB, 1 x 80 SSD, $0.333/hour, $0.0458/hour -- master 120GB SSD recommended
      # r4.large,   2vcpu, 7 ECU, 15.25GiB, EBS Only, $0.133/hour, $0.0152/hour
      # r4.xlarge,  4vcpu,  13.5 ECU, 30.5GiB, EBS Only, $0.266/hour, $0.0318/hour
      # r4.2xlarge, 8vcpu,  27 ECU, 61GiB, EBS Only, $0.532/hour, $0.0634/hour
      aws.instance_type = "t2.micro"
      
      # AWS authentication info
      aws_access_key_id = ENV['AWS_ACCESS_KEY_ID'] || "ABCDEF0123456789ABCD"
      aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY'] || "abcdef0123456/789ABCD/EF0123456789abcdef"

      aws.access_key_id = aws_access_key_id
      aws.secret_access_key = aws_secret_access_key
  
      aws.keypair_name = aws_config['keypair_name']
  
      # Amazon ECS-Optimized Amazon Linux AMI
      # visit: https://aws.amazon.com/marketplace/pp/B00U6QTYI2
      # Must first accept software terms from Amazon here:
      #  https://aws.amazon.com/marketplace/fulfillment?productId=4ce33fd9-63ff-4f35-8d3a-939b641f1931&ref_=dtl_psb_continue&region=us-east-1
      #aws.ami = "ami-92659c84"
      #override.ssh.username = "ec2-user"
  
      # Ubuntu 16.04
      aws.ami = "ami-f4cc1de2"
      override.ssh.username = aws_config['user']
  
      aws.region = aws_config['region'] # N. Virginia
  
      # This must already exist
      aws.subnet_id = aws_config['subnet_id'] # in AZ: us-east-1a
  
      aws.tags = {
        'Name' => 'name',
        'client' => 'client'
      }
  
      # These must already exist - use group ID not group name
      aws.security_groups = aws_config['security_groups'] # Group Name: default
  
      aws.region_config "us-east-1" do |region|
        region.keypair_name = aws_config['keypair_name']
        region.ami = aws_config['ami']
        region.instance_type = aws_config['instance_type']
        region.associate_public_ip = true
        region.elastic_ip = false # || 'true' creates a new Elastic IP address each time
        # block_device_mapping is ignored by aws for spot instances
        region.block_device_mapping = [{
          'DeviceName' => '/dev/sda1',
          'Ebs.VolumeSize' => aws_config['volume_size'],
          'Ebs.VolumeType' => 'gp2',
          'Ebs.SnapshotId' => 'snap-00762b50998e9113b',
          'Ebs.DeleteOnTermination' => 'true' }]
        region.ebs_optimized = false
        region.spot_instance = true
        region.spot_max_price = aws_config['spot_price']
        region.spot_valid_until = nil # default value nil means indefinitely
        region.terminate_on_shutdown = true if region.spot_max_price.to_f > 0.0
      end
    
      override.vm.provision "ansible_local" do |ansible|
        ansible.install = true
        ansible.playbook = "ansible/site.yml"
        ansible.inventory_path = "ansible/inventory"
        ansible.limit = "all" # or only "nodes" group, etc.
        #ansible.tmp_path = "/tmp/vagrant-ansible"
        ansible.extra_vars = { ansible_ssh_user: 'ubuntu' }
        #ansible.sudo = true
        #ansible.verbose = true # true or 'vv' or 'vvv' or 'vvvv' or 'vvvvv' increases verbosity
      end
  
      override.vm.provision "shell" do |s|
        s.path = "scripts/install_awscli.sh"
        s.args = ["#{aws_access_key_id}", "#{aws_secret_access_key}"]
      end

      # Assign Elastic IP to instance
      override.vm.provision :shell, inline: <<-SCRIPT
        INSTANCE_ID="`curl -s http://169.254.169.254/latest/meta-data/instance-id`"
        echo "Assigning IP: #{aws_config['eip']} to instance: $INSTANCE_ID"
        aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id #{aws_config['eip_allocation_id']}
      SCRIPT
    end #config.vm.provider :aws
  end #config.mv.define

end
