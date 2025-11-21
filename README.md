# AWS ACM Certificate Terraform Module

A Terraform module for creating and managing AWS ACM (AWS Certificate Manager) certificates.

## Features

✅ Creates public ACM certificates in the application account  
✅ Supports private certificates via AWS Private Certificate Authority  
✅ DNS and EMAIL validation methods  
✅ Subject Alternative Names (SANs) for wildcard/multi-domain certificates  
✅ Mandatory tagging for governance and cost tracking  

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Usage

### Basic Public Certificate

```hcl
module "acm_certificate" {
  source = "git::https://github.com/your-org/acm-module.git"

  certificate_name = "my-app-cert"
  domain_name      = "example.com"
  
  subject_alternative_names = [
    "*.example.com"
  ]

  validation_method = "DNS"

  # Mandatory tags
  description    = "Production SSL certificate"
  requestor      = "platform-team@company.com"
  allocation_id  = "ALLOC-12345"
  iac_repo       = "github.com/company/infrastructure"
  iac            = "terraform"
  iac_version    = "1.0.0"

  # Optional custom tags
  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

### Private Certificate

```hcl
module "private_certificate" {
  source = "git::https://github.com/your-org/acm-module.git"

  certificate_name = "internal-app-cert"
  domain_name      = "internal.example.com"
  
  # Provide AWS Private CA ARN
  certificate_authority_arn = "arn:aws:acm-pca:us-east-1:123456789012:certificate-authority/xxxxx"

  # Mandatory tags
  description    = "Internal service certificate"
  requestor      = "devops@company.com"
  allocation_id  = "ALLOC-67890"
  iac_repo       = "github.com/company/infrastructure"
  iac            = "terraform"
  iac_version    = "1.0.0"

  tags = {
    Environment = "production"
    Type        = "Private"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| certificate_name | Name of the ACM certificate | `string` | n/a | yes |
| domain_name | Domain name for the certificate | `string` | n/a | yes |
| subject_alternative_names | Additional domain names (e.g., *.example.com) | `list(string)` | `[]` | no |
| validation_method | Validation method (DNS, EMAIL, or NONE) | `string` | `"DNS"` | no |
| certificate_authority_arn | ARN of AWS Private CA (for private certs) | `string` | `null` | no |
| description | Description of the certificate | `string` | n/a | yes |
| requestor | Name or email of requestor | `string` | n/a | yes |
| allocation_id | Allocation ID for cost tracking | `string` | n/a | yes |
| iac_repo | Repository URL for IaC code | `string` | n/a | yes |
| iac | IaC tool being used | `string` | `"terraform"` | no |
| iac_version | Version of IaC code/module | `string` | n/a | yes |
| tags | Additional custom tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| certificate_arn | ARN of the ACM certificate |
| certificate_id | ID of the ACM certificate |
| certificate_domain_name | Domain name of the certificate |
| certificate_status | Status of the certificate |
| certificate_type | Type of certificate (AMAZON_ISSUED or PRIVATE) |
| domain_validation_options | Domain validation options (use with separate Route53/DNS module) |

### Tag Management

The module automatically applies these tags to all certificates:

**Mandatory Tags** (from variables):
- `Name` - certificate_name
- `Is:description` - description
- `Is:requestor` - requestor
- `Is:allocation-id` - allocation_id
- `Is:iac-repo` - iac_repo
- `Is:iac` - iac
- `Is:iac-version` - iac_version

**Custom Tags** (from tags variable):
- Any additional tags you provide

**Note:** Tag changes outside Terraform are ignored (lifecycle: `ignore_changes = [tags]`)


## Best Practices

1. **Use wildcard certificates** - For multiple subdomains
2. **Tag appropriately** - All mandatory tags must be provided
3. **Use private certs** - Only for internal services (cost consideration)
4. **Separate concerns** - Validation is handled by Route53/DNS modules

## Module Structure

```
acm/
├── main.tf              # ACM certificate resource
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── versions.tf          # Terraform version requirements
├── terraform.tfvars     # Example values
├── README.md            # This file
└── examples/
    ├── basic/
    └── private-certificate/
```
