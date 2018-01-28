This project allows you to explore using docker and docker-compose on the following VMs and cloud providers:

1. VirtualBox
2. Azure
3. Amazon

On Amazon, it is possible to use EC2 spot instances to save on the cost of cloud VMs.  Spot instances could save you more than 50% off the cost of on-demand instances.

### PEM File KeyPair Fingerprints

Visit [Verifying Your Key Pair's Fingerprint](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#verify-key-pair-fingerprints)

AWS provides the ability to create an RSA keypair, and the opportunity to download it to your local machine only right after it is created.  The downloaded file has a .pem extension, and can be viewed in a text editor, and looks somewhat like the following (truncated below):

	-----BEGIN RSA PRIVATE KEY-----
	MIIEowIBAAKCAQEAp2kgFw2moqs4EOd8rqkfj3lAm+IjqVlI+TgqJJzABMcY7Oa+PaFUBX4dD1L3
	iyeAfLhqZvrbDDpj/6mkR6hTHo9wrIYU+iMrM7OnRCSFaP5rfuPVjkWOJg4vMHF0+cfTlG9amrSu
	-----END RSA PRIVATE KEY-----

AWS displays a fingerprint next to the name of the keypair.  To verify this fingerprintIf you created your key pair using AWS, you can use the OpenSSL tools to generate a fingerprint from the private key file:

	openssl pkcs8 -in private_key.pem -inform PEM -outform DER -topk8 -nocrypt | openssl sha1 -c

If you created your key pair using a third-party tool and uploaded the public key to AWS, you can use the OpenSSL tools to generate a fingerprint from the private key file on your local machine:

	openssl rsa -in path_to_private_key -pubout -outform DER | openssl md5 -c


### KeyPair and Certificate Container (ie, file) Formats

Visit [Diff Between PEM and key files](https://serverfault.com/questions/9708/what-is-a-pem-file-and-how-does-it-differ-from-other-openssl-generated-key-file)	
