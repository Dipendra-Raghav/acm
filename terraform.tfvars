# Certificate Configuration
certificate_name = "test-certificate"
domain_name      = "test.example.com"

# Subject Alternative Names (SANs)
subject_alternative_names = [
  "*.test.example.com"
]

# Validation Method
validation_method = "DNS"

# Private Certificate (optional - leave null for public certificate)
# certificate_authority_arn = null

# Mandatory Tags
description    = "Test ACM certificate"
requestor      = "devops@example.com"
allocation_id  = "TEST-001"
iac_repo       = "github.com/org/acm-module"
iac            = "terraform"
iac_version    = "1.0.0"

# Optional Custom Tags
tags = {
  Environment = "test"
  Team        = "platform"
}
