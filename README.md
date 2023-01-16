This project allows you to use Vagrant to create VMs on the following VM/cloud providers:

1. VirtualBox
2. Azure
3. Amazon

On Amazon, the project allows you to use EC2 spot instances to save on the cost of cloud VMs.  Spot instances could save you more than 50% off the cost of on-demand instances.
Visit [Amazon EC2 Spot Instances Pricing](https://aws.amazon.com/ec2/spot/pricing/)
and [Amazon EC2 Pricing](https://aws.amazon.com/ec2/pricing/on-demand/).

Moreover, the project uses Ansible to setup docker and docker-compose on the VM to experiment with containers, and composing containerized applications.

You can first create a VM using Virtualbox so that you can experiment locally, and then provision a similar VM on AWS or Azure for a cloud experience.

# Running Vagrant on Windows

When this project was first committed, it ran on Vagrant 1.8.7 and Virtualbox 5.0.36 r114008.  However, as a result of updates to Windows, updates to Virtualbox and Vagrant were apparently necessitated.

As of this edit, the Vagrantfile runs correctly with the following versions of Windows, Virtualbox, and Vagrant:

	Windows 10 Home version 1903
	Virtualbox version 6.0.12 r133076 (Qt5.6.2)
	Vagrant version 2.2.6
	Docker version 17.05.0-ce, build 89658be
	docker-compose version 1.24.1, build 4667896

## Cygwin 64

Install Cygwin 64 for running vagrant commands, and working with Ruby as necessary.

	Ruby on Cygwin 64: ruby 2.6.4p104 (2019-08-28 revision 67798) [x86_64-cygwin]

# Running Vagrant on Intel MacOS (1/15/2023)

As of this edit, the Vagrantfile runs correctly with the following versions of MacOS, Virtualbox, and Vagrant:

	MacOS Catalina 10.15.7
	Virtualbox version 6.1.30 r148432 (Qt5.6.3)
	Vagrant version 2.3.4
	Docker version 20.10.22, build 3a2c30b
	Docker Compose version v2.15.1

## Re-installing Vagrant

It is best to uninstall all Vagrant plugins before upgrading Vagrant.  Use the following commands to get a list of plugins:

	vagrant plugin list
	vagrant plugin unintall <plugin-name>


### Install vagrant-aws for spot instances

For creating spot instances, this Vagrantfile requires a specific version of vagrant-aws.  In order to install it,
visit [vagrant_spot_instance.md](https://gist.github.com/ozzyjohnson/d62b0c8183f0d4d7448e).

First install fog-ovirt as follows:

	vagrant plugin install --plugin-version 1.0.1 fog-ovirt

then install vagrant-aws

### Notes on Vagrant

Vagrant customizes ["base boxes"](https://www.vagrantup.com/docs/boxes/base.html) by using Provisioners such as shell scripts, Ansible playbooks, Puppet manifests, Chef cookbooks and recipes, and Salt states.

Vagrant base boxes are are configured with the default "vagrant" user and the default "vagrant" password, and an insecure keypair for ssh access.  When Vagrant boots up a fresh VM on Virtualbox, the insecure keypair is replaced with a fresh keypair for "improving security".  You can login into the VM using the command:

	vagrant ssh hostname

Password-less sudo is also configured in the base boxes.


## Importing a KeyPair into AWS

AWS allows you to generate your own key and import it into AWS.  You can generate a keypair using ssh-keygen; follow the procedure below to generate a keypair.  Once generated, you can import the keypair (actually, only the public key of the keypair) and verify fingerprints (see below).

The public key file has a format that can be imported by AWS without issue.  Moreover, this key can be used across regions, unlike AWS generated keys.  Additionally, the private key only exists on your machine.  Of course, if this key is compromised, then all your regions will be compromised (although proper ingress rules within security groups may provide an additional level of protection). 



### PEM File KeyPair Generation Using ssh-keygen

The following command generates public and private key files (default names are id_rsa and id_rsa.pub:

	ssh-keygen -t rsa -b 2048 -C "My comment"

Follow the prompts; you may leave the passphrase blank by just hitting enter at the prompt.



### PEM File KeyPair Fingerprints

Visit [Verifying Your Key Pair's Fingerprint](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#verify-key-pair-fingerprints)

AWS provides the ability to create an RSA keypair, and the opportunity to download it to your local machine only right after it is created.  The downloaded file has a .pem extension, and can be viewed in a text editor, and looks somewhat like the following (truncated below):

	-----BEGIN RSA PRIVATE KEY-----
	MIIEowIBAAKCAQEAp2kgFw2moqs4EOd8rqkfj3lAm+IjqVlI+TgqJJzABMcY7Oa+PaFUBX4dD1L3
	iyeAfLhqZvrbDDpj/6mkR6hTHo9wrIYU+iMrM7OnRCSFaP5rfuPVjkWOJg4vMHF0+cfTlG9amrSu
	-----END RSA PRIVATE KEY-----

AWS displays a fingerprint next to the name of the keypair.  To verify this fingerprint, if you created your key pair using AWS, you can use the OpenSSL tools to generate a fingerprint from the private key file:

	openssl pkcs8 -in private_key.pem -inform PEM -outform DER -topk8 -nocrypt | openssl sha1 -c

If you created your key pair using a third-party tool and uploaded the public key to AWS, you can use the OpenSSL tools to generate a fingerprint from the private key file on your local machine:

	openssl rsa -in path_to_private_key -pubout -outform DER | openssl md5 -c



### PEM File KeyPair Generation using OpenSSL

The following command generates a private key in PEM format:

	openssl genrsa -des3 -out privkey.pem 2048

The following command generates the public key file from the private key above (also in PEM format):

	openssl rsa -in privkey.pem -pubout -out key.pub



### KeyPair and Certificate Container (i.e., file) Formats

Visit [Diff Between PEM and key files](https://serverfault.com/questions/9708/what-is-a-pem-file-and-how-does-it-differ-from-other-openssl-generated-key-file)	



### Troubleshooting

If you are having trouble, ssh'ing into your AWS instance:

	Check AWS Security Group ingress rules for allowed IPs
	Assure that the public certificate on AWS is in ssh-rsa format

Use the -v option on ssh to get more detailed troubleshooting information:

	ssh -v user-at-hostname

Use the debug option with Vagrant for more troubleshooting info (this is very verbose)

	VAGRANT_LOG=debug vagrant ssh vagrant_machine_name


## Docker Compose and Docker Desktop (added 1/15/2023)

Docker compose has become a two-headed beast:

	1. old style 'docker-compose' command - on Linux, this is available by installing Docker and Docker Compose separately
	2. new style 'docker compose' command - on Linux, Mac and Windows, this is available as a part of Docker Desktop

On a Linux machine, Docker Desktop installs itself in its own Linux VM; nested Linux VM environments are not supported.  Therefore, a Linux VM on AWS cannot support the installation of Docker Desktop so the old style docker-compose is the only option.

[Why does Docker Desktop for Linux run a VM?](https://docs.docker.com/desktop/faqs/linuxfaqs/#why-does-docker-desktop-for-linux-run-a-vm)


### Compose file format compatibility matrix

	| Compose file version | Docker Engine |
	| -------------------- | ------------- |
	| Compose Spec         | 19.03.0+      |
	| 3.8                  | 19.03.0+      |
	| 3.7                  | 18.06.0+      |
	| 3.6                  | 18.02.0+      |
	| 3.5                  | 17.12.0+      |
	| 3.4                  | 17.09.0+      |
	| 3.3                  | 17.06.0+      |
	| 3.2                  | 17.04.0+      |
	| 3.1                  | 1.13.1+       |
	| 3.0                  | 1.13.0+       |
	| 2.3                  | 17.06.0+      |
	| 2.2                  | 1.13.0+       |
	| 2.1                  | 1.12.0+       |
	| 2.0                  | 1.10.0+       |
	| 1.0                  | 1.9.1+        |

# Output From Shell Config

The last piece of bringing up an AWS VM is to expand the disk size from 8G to 30G.  You should see the following:

    dockerhost-aws: Running: script: Assign EIP; Resize root volume
    dockerhost-aws: Executing as: ubuntu
    dockerhost-aws: Assigning EIP: 10.0.0.0 to instance: i-<<17-digit hex value>>
    dockerhost-aws: {
    dockerhost-aws:     "AssociationId": "eipassoc-<<17-digit hex value>>"
    dockerhost-aws: }
    dockerhost-aws: Instance ID: i-<<17-digit hex value>>, Volume ID: vol-<<17-digit hex value>>
    dockerhost-aws: Resizing /dev/sda1
    dockerhost-aws: {
    dockerhost-aws:     "VolumeModification": {
    dockerhost-aws:         "TargetSize": 30,
    dockerhost-aws:         "TargetVolumeType": "gp2",
    dockerhost-aws:         "ModificationState": "modifying",
    dockerhost-aws:         "VolumeId": "vol-<<17-digit hex value>>",
    dockerhost-aws:         "TargetIops": 100,
    dockerhost-aws:         "StartTime": "2019-10-20T20:36:06.000Z",
    dockerhost-aws:         "Progress": 0,
    dockerhost-aws:         "OriginalVolumeType": "gp2",
    dockerhost-aws:         "OriginalIops": 100,
    dockerhost-aws:         "OriginalSize": 8
    dockerhost-aws:     }
    dockerhost-aws: }
    dockerhost-aws: Rebooting...
