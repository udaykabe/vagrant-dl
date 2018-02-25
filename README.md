This project allows you to explore using docker and docker-compose on the following VMs and cloud providers:

1. VirtualBox
2. Azure
3. Amazon

On Amazon, it is possible to use EC2 spot instances to save on the cost of cloud VMs.  Spot instances could save you more than 50% off the cost of on-demand instances.


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

	ssh -v user@host

Use the debug option with Vagrant for more troubleshooting info (this is very verbose)

	VAGRANT_LOG=debug vagrant ssh vagrant_machine_name


## Compose file format compatibility matrix

	| Compose file version | Docker Engine |
	| -------------------- | ------------- |
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

