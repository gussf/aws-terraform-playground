fmt:
	terraform fmt

vld:
	terraform validate

plan:
	terraform plan

apply:
	terraform apply

applyf:
	terraform apply --auto-approve

destroy:
	terraform destroy --auto-approve