variable "certificate_name" {
  description = "Name of the ACM certificate"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "List of additional domain names to be included in the certificate (e.g., *.example.com)"
  type        = list(string)
  default     = []
}

variable "validation_method" {
  description = "Method to use for validation. Use DNS for public certificates, NONE for private certificates"
  type        = string
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "EMAIL", "NONE"], var.validation_method)
    error_message = "Validation method must be DNS, EMAIL, or NONE."
  }
}

variable "certificate_authority_arn" {
  description = "ARN of AWS Private Certificate Authority for creating private certificates. If provided, creates a private certificate. If null (default), creates a public certificate."
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the certificate"
  type        = string
}

variable "requestor" {
  description = "Name or email of the person requesting the certificate"
  type        = string
}

variable "allocation_id" {
  description = "Allocation ID for cost tracking"
  type        = string
}

variable "iac_repo" {
  description = "Repository URL for the IaC code"
  type        = string
}

variable "iac" {
  description = "IaC tool being used (e.g., terraform)"
  type        = string
  default     = "terraform"
}

variable "iac_version" {
  description = "Version of the IaC code or module"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
