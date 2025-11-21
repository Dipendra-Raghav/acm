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
| certificate_status | Status of the certificate (PENDING_VALIDATION, ISSUED, etc.) |
| certificate_type | Type of certificate (AMAZON_ISSUED or PRIVATE) |
| domain_validation_options | DNS validation records (for DNS validation method) |

## Certificate Validation

### DNS Validation

The module creates certificates with DNS validation by default. For validation:

1. Certificate is created with status `PENDING_VALIDATION`
2. Use the `domain_validation_options` output to get DNS records
3. Create these DNS records in your DNS provider (Route53, BlueCat, etc.)
4. AWS ACM automatically validates once DNS records are detected

```hcl
output "validation_records" {
  description = "Create these DNS records to validate the certificate"
  value       = module.acm_certificate.domain_validation_options
}
```

### EMAIL Validation

Set `validation_method = "EMAIL"` to use email validation. AWS will send validation emails to:
- admin@yourdomain.com
- administrator@yourdomain.com
- hostmaster@yourdomain.com
- postmaster@yourdomain.com
- webmaster@yourdomain.com

## Certificate Types

### Public Certificates (Default)

```hcl
certificate_authority_arn = null  # or omit this variable
```

- Free
- Requires validation (DNS or EMAIL)
- Use for public websites, APIs

### Private Certificates

```hcl
certificate_authority_arn = "arn:aws:acm-pca:..."
```

- Costs $0.75/month per certificate + PCA costs (~$400/month)
- No validation required
- Use for internal services

## Important Notes

### Regional Requirements

- **CloudFront:** Certificates must be in `us-east-1`
- **ALB/NLB:** Certificates must be in same region as load balancer
- **API Gateway:** Regional certs in same region, edge certs in `us-east-1`

### Validation Methods

| Method | Best For | Speed | Automation |
|--------|----------|-------|------------|
| DNS | Production | Fast (minutes) | Automatable |
| EMAIL | Testing | Slow (manual) | Manual approval needed |
| NONE | Private certs only | N/A | No validation |

### Wildcard Certificates

```hcl
domain_name = "example.com"
subject_alternative_names = [
  "*.example.com"      # All subdomains
  "*.api.example.com"  # All API subdomains
]
```

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

## Examples

See `examples/` directory for complete working examples:

- **basic/** - Simple certificate with manual DNS validation
- **private-certificate/** - Private certificate using AWS Private CA

## Troubleshooting

### Certificate Stuck in PENDING_VALIDATION

**Cause:** DNS validation records not created  
**Solution:** Create the DNS records from `domain_validation_options` output

### "Domain does not exist" Error

**Cause:** Using non-existent domain for testing  
**Solution:** Use a real domain you own, or use EMAIL validation for testing

### Private Certificate Authority Not Found

**Cause:** Invalid PCA ARN or PCA not active  
**Solution:** Verify PCA exists and is in ACTIVE state

## Best Practices

1. **Use DNS validation** - Faster and can be automated
2. **Use wildcard certificates** - For multiple subdomains
3. **Tag appropriately** - All mandatory tags must be provided
4. **Monitor expiration** - Set up alerts for certificate renewal
5. **Use private certs** - Only for internal services (cost consideration)

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

## Support

For issues or questions, contact the Platform Engineering team.

## License

Internal use only
