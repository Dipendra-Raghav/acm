resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method
  certificate_authority_arn = var.certificate_authority_arn

  tags = merge(
    var.tags,
    {
      Name                = var.certificate_name
      "Is:description"    = var.description
      "Is:requestor"      = var.requestor
      "Is:allocation-id"  = var.allocation_id
      "Is:iac-repo"       = var.iac_repo
      "Is:iac"            = var.iac
      "Is:iac-version"    = var.iac_version
    }
  )

  lifecycle {
    ignore_changes        = [tags]
  }
}
