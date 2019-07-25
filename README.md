# devops-coding

PRE-REQ

INSTALL TERRAFORM, ANSIBLE AND AWSCLI: on the machine you will run the code from.

Configure AWS CLI with you AWS ACCESS AND SECRET KEY, if you don't have one use the link below to create one.
https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html

Terraform v0.12.4
provider.aws v2.19.0
aws-cli/1.16.190
ansible 2.8.2

In the variables.tf set the path to your private and public key path, or create a key with openssl. Also the the region is set to us-eat-1, if deploying to another region change the AMI ID in the main.tf to use Ubuntu 16.04 LTS from the region of you choice.

In the main.tf change the path of the private key in of the remote exec for each environment, will be two connection resource which will have a path of {file("~/.ssh/id_rsa")} replace if you private key location is differnet. 

STEPS TO RUN
1. Modify the variables.tf (public and private key)
2. Run terraform init in the directory with the code
3. Run terraform apply to standup the environment and it will also call ansible
