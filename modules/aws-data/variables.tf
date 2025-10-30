variable "use_localstack" {
  description = "When true, avoid querying unsupported AWS data sources and return mock values."
  type        = bool
  default     = false
}

