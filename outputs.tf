output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.main.arn
}

output "certificate_id" {
  description = "ID of the ACM certificate"
  value       = aws_acm_certificate.main.id
}

output "certificate_domain_name" {
  description = "Domain name of the certificate"
  value       = aws_acm_certificate.main.domain_name
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = aws_acm_certificate.main.status
}

output "certificate_type" {
  description = "Type of the certificate (AMAZON_ISSUED or PRIVATE)"
  value       = var.certificate_authority_arn != null ? "PRIVATE" : "AMAZON_ISSUED"
}

output "domain_validation_options" {
  description = "Set of domain validation objects for DNS validation. Use this output in a separate Route53 module to create validation records."
  value       = aws_acm_certificate.main.domain_validation_options
}
