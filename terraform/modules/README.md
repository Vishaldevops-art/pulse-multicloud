# Terraform modules — you write these (weeks 3–5)

Each module gets `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf` (required_providers only, **no provider block**).
Spec for each below. Write it yourself first, then ask Claude to review it before you `plan`.

## azure-network (Week 3 D4 / Week 4 D2)
- Inputs: `name`, `location`, `address_space` (list), `aks_subnet_cidr` (default `10.10.0.0/20`)
- Creates: resource group, VNet, AKS subnet, NSG associated with the subnet
- Outputs: `resource_group_name`, `vnet_id`, `aks_subnet_id`

## azure-aks (Week 4 D4)
- Inputs: `name`, `location`, `resource_group_name`, `subnet_id`, `node_count` (default 1), `node_vm_size` (default `Standard_B2s`)
- Creates: ACR (Basic), AKS (`sku_tier = "Free"`, system-assigned identity, Azure CNI Overlay,
  `oidc_issuer_enabled = true`, `workload_identity_enabled = true`), `AcrPull` role assignment for the kubelet identity
- Outputs: `cluster_name`, `acr_login_server`, `oidc_issuer_url`
- Cost: control plane free; you pay for the node VM(s), public IP and load balancer while running. **Destroy after each lab.**

## aws-network (Week 5 D2)
- Inputs: `name`, `cidr_block`, `az_count` (default 2)
- Creates: VPC, public subnets (tag `kubernetes.io/role/elb = 1`), Internet Gateway, route table
- Lab shortcut: nodes in public subnets, so no NAT Gateway (~$33/month). Production uses private subnets + NAT per AZ
  or VPC endpoints — be ready to explain the trade-off.
- Outputs: `vpc_id`, `public_subnet_ids`

## aws-eks (Week 5 D4)
- Inputs: `name`, `vpc_id`, `subnet_ids`, `node_instance_type` (default `t3.medium`), `desired_size` (default 2)
- Creates: EKS cluster + IAM role, managed node group + IAM role (worker, CNI, ECR read-only policies), ECR repository,
  EKS access entry for your admin role, EKS Pod Identity agent add-on
- Later: AWS Load Balancer Controller (Helm) with a Pod Identity role
- Outputs: `cluster_name`, `cluster_endpoint`, `ecr_repository_url`
- Cost: control plane ~$0.10/hr + 2× t3.medium + ALB ≈ $1–3 per 3-hour session. **Destroy after each lab.**
- Write it yourself first (best for learning), then compare with the community `terraform-aws-modules/eks` module.
