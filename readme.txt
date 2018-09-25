Terraform Commands(secret.tfvars contains aws secrets and is not checked in):
AWS
terraform plan -var-file ../../secret_aws.tfvars
terraform apply -var-file ../../secret_aws.tfvars

OPENSTACK
terraform plan -var-file ../../secret_openstack.tfvars
terraform apply -var-file ../../secret_openstack.tfvars



