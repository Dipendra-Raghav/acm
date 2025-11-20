# AWS ACM Certificate Terraform Module

A comprehensive Terraform module for creating and managing AWS ACM (AWS Certificate Manager) certificates with support for cross-account DNS validation and private certificates. This module follows your organization's single-module, single-repo structure.

## Key Features

✅ **Public ACM certificates** - Created in the "local" application account  
✅ **Cross-account DNS validation** - Validated in the "dns-corp" AWS account  
✅ **Dynamic hosted zone lookup** - No hard-coded zone IDs required  
✅ **Private ACM certificates** - Support via AWS Private CA or data import  
✅ **Multiple validation methods** - DNS (recommended) and Email  
✅ **Subject Alternative Names (SANs)** - Wildcard and multi-domain support  
✅ **Automated certificate validation** - Optional waiting for validation completion

## Architecture

### Cross-Account Certificate Validation

```
┌─────────────────────────────┐         ┌─────────────────────────────┐
│  Local Application Account  │         │  DNS-Corp Account           │
│                             │         │                             │
│  ┌───────────────────────┐  │         │  ┌───────────────────────┐  │
│  │ Public ACM Certificate│  │         │  │ Route53 Hosted Zone   │  │
│  │ example.com           │──┼────────▶│  │ example.com           │  │
│  │ *.example.com         │  │         │  │                       │  │
│  └───────────────────────┘  │         │  └───────────────────────┘  │
│                             │         │  ┌───────────────────────┐  │
│                             │         │  │ DNS Validation        │  │
│                             │         │  │ Records (_acme-...)   │  │
│                             │         │  └───────────────────────┘  │
└─────────────────────────────┘         └─────────────────────────────┘
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Usage Examples

### Cross-Account DNS Validation (Recommended)

Certificate created in local account, DNS validation in dns-corp account:

```hcl
# Provider for local application account
provider "aws" {
  region = "us-east-1"
  # Configure authentication for local account
}

# Provider for dns-corp account
provider "aws" {
  alias  = "dns"
  region = "us-east-1"
  
  assume_role {
    role_arn = "arn:aws:iam::222222222222:role/Route53ManagementRole"
  }
}

module "acm_certificate" {
  source = "git::https://github.com/your-org/acm-module.git"

  providers = {
    aws     = aws
    aws.dns = aws.dns
  }

  certificate_name = "my-app-cert"
  domain_name      = "example.com"
  
  subject_alternative_names = [
    "*.example.com",
    "www.example.com"
  ]

  validation_method        = "DNS"
  create_route53_records   = true
  
  # Lookup zone dynamically - no hard-coded IDs!
  lookup_route53_zone      = true
  route53_zone_name        = "example.com."
  
  wait_for_validation      = true

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

### Basic Public Certificate (Manual DNS Validation)

```hcl
module "acm_certificate" {
  source = "git::https://github.com/your-org/acm-module.git"

  certificate_name = "basic-cert"
  domain_name      = "example.com"
  
  subject_alternative_names = [
    "*.example.com"
  ]

  validation_method = "DNS"

  tags = {
    Environment = "production"
  }
}

# Get validation records to create manually
output "validation_records" {
  value = module.acm_certificate.domain_validation_options
}
```

### Private ACM Certificate

```hcl
module "private_certificate" {
  source = "git::https://github.com/your-org/acm-module.git"

  certificate_name = "internal-app-cert"
  domain_name      = "internal.example.com"
  
  # Provide your Private CA ARN
  certificate_authority_arn = "arn:aws:acm-pca:us-east-1:123456789012:certificate-authority/12345678-1234-1234-1234-123456789012"

  tags = {
    Environment = "production"
    Type        = "Private"
  }
}
```

### Using Existing Private Certificate

```hcl
module "existing_cert" {
  source = "git::https://github.com/your-org/acm-module.git"

  certificate_name = "existing-private-cert"
  domain_name      = "app.internal.example.com"
  
  use_existing_certificate     = true
  existing_certificate_types   = ["PRIVATE"]
  existing_certificate_statuses = ["ISSUED"]

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| certificate_name | Name of the ACM certificate | `string` | n/a | yes |
| domain_name | Domain name for the certificate | `string` | n/a | yes |
| subject_alternative_names | List of additional domain names | `list(string)` | `[]` | no |
| validation_method | Method to use for validation (DNS or EMAIL) | `string` | `"DNS"` | no |
| **Cross-Account Configuration** |
| create_route53_records | Create Route53 records for DNS validation | `bool` | `false` | no |
| lookup_route53_zone | Lookup Route53 zone by name (no hard-coded IDs) | `bool` | `false` | no |
| route53_zone_name | Route53 zone name (when lookup_route53_zone=true) | `string` | `""` | no |
| route53_zone_id | Route53 zone ID (when lookup_route53_zone=false) | `string` | `""` | no |
| route53_zone_private | Whether the Route53 zone is private | `bool` | `false` | no |
| **Private Certificate Configuration** |
| use_existing_certificate | Use existing certificate instead of creating new | `bool` | `false` | no |
| certificate_authority_arn | ARN of AWS Private CA for private certificates | `string` | `null` | no |
| existing_certificate_types | Filter for existing cert types (PRIVATE, AMAZON_ISSUED, IMPORTED) | `list(string)` | `["AMAZON_ISSUED", "PRIVATE"]` | no |
| existing_certificate_statuses | Filter for existing cert statuses | `list(string)` | `["ISSUED"]` | no |
| use_most_recent_certificate | Use most recent when multiple certs match | `bool` | `true` | no |
| **Other Configuration** |
| wait_for_validation | Wait for certificate validation | `bool` | `false` | no |
| tags | Map of tags to add to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| certificate_arn | ARN of the ACM certificate (created or existing) |
| certificate_id | ID of the ACM certificate |
| certificate_domain_name | Domain name of the certificate |
| certificate_status | Status of the certificate |
| certificate_type | Type: AMAZON_ISSUED, PRIVATE, or IMPORTED |
| domain_validation_options | Domain validation options |
| validation_record_fqdns | FQDNs of validation records |
| route53_zone_id | Route53 zone ID used (looked up or provided) |
| route53_zone_name | Route53 zone name (if looked up) |
| is_existing_certificate | Whether existing certificate is used |

## Detailed Configuration Guides

### Cross-Account DNS Validation Setup

#### Prerequisites

1. **Local Account Permissions:**
   - `acm:RequestCertificate`
   - `acm:DescribeCertificate`
   - `sts:AssumeRole`

2. **DNS-Corp Account Permissions:**
   - `route53:GetHostedZone`
   - `route53:ChangeResourceRecordSets`

3. **IAM Role in DNS-Corp Account:**

```hcl
resource "aws_iam_role" "route53_management" {
  name = "Route53ManagementRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::111111111111:root"  # Local account
      }
      Action = "sts:AssumeRole"
    }]
  })
}
```

#### Provider Configuration

```hcl
provider "aws" {
  region = "us-east-1"
  # Local account configuration
}

provider "aws" {
  alias  = "dns"
  region = "us-east-1"
  
  assume_role {
    role_arn = "arn:aws:iam::DNS_CORP_ACCOUNT:role/Route53ManagementRole"
  }
}
```

### Dynamic Hosted Zone Lookup

Instead of hard-coding zone IDs, use dynamic lookup:

```hcl
# ❌ Hard-coded (not recommended)
lookup_route53_zone = false
route53_zone_id     = "Z1234567890ABC"

# ✅ Dynamic lookup (recommended)
lookup_route53_zone = true
route53_zone_name   = "example.com."  # Note the trailing dot
```

Benefits:
- No hard-coded IDs
- Works across environments
- Automatically finds the correct zone
- Easier to maintain

### Private Certificates

#### Creating New Private Certificate

Requires AWS Private Certificate Authority:

```hcl
module "private_cert" {
  source = "..."
  
  domain_name               = "internal.example.com"
  certificate_authority_arn = var.pca_arn  # Your PCA ARN
}
```

#### Using Existing Private Certificate

Import existing certificate via data source:

```hcl
module "existing_cert" {
  source = "..."
  
  domain_name              = "internal.example.com"
  use_existing_certificate = true
  existing_certificate_types = ["PRIVATE"]
}
```

## Examples

Complete examples are provided in the `examples/` directory:

- **`basic/`** - Simple certificate with manual DNS validation
- **`route53-validation/`** - Automated DNS validation with Route53
- **`cross-account-validation/`** - Certificate in local account, DNS in dns-corp
- **`private-certificate/`** - Private certificates and existing cert import

## Important Notes

### Regional Requirements

- **CloudFront:** Certificates must be in `us-east-1`
- **ALB/NLB:** Certificates must be in the same region as the load balancer
- **API Gateway:** Regional certs in same region, edge certs in `us-east-1`

### Validation Methods

**DNS Validation (Recommended):**
- Fully automatable
- Faster (minutes vs hours)
- Works with cross-account setup
- Can be scripted

**Email Validation:**
- Requires manual intervention
- Slower process
- Emails sent to domain contacts
- Not recommended for automation

### Certificate Types

| Type | Use Case | Validation | Cost |
|------|----------|------------|------|
| AMAZON_ISSUED (Public) | Public websites, APIs | DNS/Email required | Free |
| PRIVATE | Internal services | None | $0.75/month + PCA costs |
| IMPORTED | Externally issued | Pre-validated | Free |

### Wildcard Certificates

```hcl
domain_name = "example.com"
subject_alternative_names = [
  "*.example.com"      # Covers all subdomains
  "*.api.example.com"  # Covers all api subdomains
]
```

## Best Practices

1. **Use cross-account validation** - Keep DNS management centralized in dns-corp
2. **Enable dynamic zone lookup** - Avoid hard-coding zone IDs
3. **Use DNS validation** - Faster and automatable
4. **Tag all certificates** - For cost tracking and lifecycle management
5. **Enable wait_for_validation in production** - Ensure cert is ready before use
6. **Use wildcard certificates** - For multiple subdomains
7. **Implement certificate rotation** - Automate renewal processes
8. **Monitor expiration** - Set up CloudWatch alarms

## Troubleshooting

### Cross-Account Validation Issues

**Problem:** "AccessDenied" when creating validation records

**Solution:**
- Verify assume_role ARN is correct
- Check trust policy in dns-corp account
- Ensure Route53 permissions are granted

### Zone Lookup Issues

**Problem:** "No hosted zone found"

**Solution:**
- Verify zone name includes trailing dot: `example.com.`
- Check zone exists in dns-corp account
- Ensure correct provider (aws.dns) is used

### Private Certificate Issues

**Problem:** "Certificate Authority not found"

**Solution:**
- Verify PCA ARN is correct
- Ensure PCA is in ACTIVE state
- Check IAM permissions for acm-pca

## Module Structure

```
acm/
├── main.tf                          # Main resources and data sources
├── variables.tf                     # Input variables
├── outputs.tf                       # Output values
├── versions.tf                      # Terraform and provider versions
├── README.md                        # This file
├── terraform.tfvars                 # Example variable values
└── examples/
    ├── basic/                       # Basic usage
    ├── route53-validation/          # Automated validation
    ├── cross-account-validation/    # Cross-account setup
    └── private-certificate/         # Private certificates
```

## Support

For issues, questions, or contributions, please contact the Platform Engineering team.

## License

Internal use only - Your Organization
