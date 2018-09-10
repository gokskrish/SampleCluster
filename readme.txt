Terraform Commands(secret.tfvars contains aws secrets and is not checked in):
terraform plan -var-file ../../secret.tfvars
terraform apply -var-file ../../secret.tfvars
