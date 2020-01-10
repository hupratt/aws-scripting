## Create AMI on AWS to be able to spin up a cluster of EC2 virtual machines

sudo apt install packer -y
packer validate packer.json 
packer build packer.json