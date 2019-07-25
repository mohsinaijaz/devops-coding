# devops-coding

PRE-REQ

Install the following: I recommend using brew to install

1. TERRAFORM v0.12.4
2. ANSIBLE 2.8.2
3. AWSCLI

Configure AWS CLI with you AWS ACCESS AND SECRET KEY, if you don't have one use the link below to create one.
https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html

In the variables.tf set the path to your private and public key path, or create a key with openssl. Also the the region is set to us-eat-1, if deploying to another region change the AMI ID in the main.tf to use Ubuntu 16.04 LTS from the region of you choice.

In the main.tf change the path of the private key in of the remote exec for each environment, will be two connection resource which will have a path of {file("~/.ssh/id_rsa")} replace if you private key location is different.

STEPS TO RUN
1. Modify the variables.tf (public and private key)
2. Modify the main.tf to the path of the private key in the connection resource
3. Run terraform init in the directory with the code
4. Run terraform apply to standup the environment and it will also call Ansible as a local exec
