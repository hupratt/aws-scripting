# Create AMI on AWS to be able to spin up a cluster of EC2 virtual machines
```
sudo apt install packer -y
packer validate packer.json 
packer build packer.json
```
## Install the AWS provider plugin
```
terraform int
```
## Dry-run check
```
terraform plan
```
## Provision the infrastructure
```
terraform apply --var-file=variables.tfvars
```