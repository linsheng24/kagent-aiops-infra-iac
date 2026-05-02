variable "linode_token" {
  description = "Token for the linode provider"
  type        = string
  default     = ""
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "gemini_api_key" {
  description = "Google Gemini API key for kagent"
  type        = string
  sensitive   = true
}

variable "keep_secret_key" {
  description = "Secret key for Keep alert management (used for JWT signing and NextAuth)"
  type        = string
  sensitive   = true
}

variable "discord_webhook_url" {
  description = "Discord webhook URL for Keep alert notifications"
  type        = string
  sensitive   = true
}
