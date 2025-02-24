variable "location" {
  type        = string
  default     = "westus"
  description = "location of resource"
}


variable "sql_admin_password" {
  type        = string
  sensitive   = true
  description = "password for sql db admin"

}

variable "client_id" {
  type = string
  sensitive = true

}

variable "client_secret" {
  type = string
  sensitive = true

}
variable "subscription_id" {
  type = string
  sensitive = true

}

variable "tenant_id" {
  type = string
  sensitive = true
}