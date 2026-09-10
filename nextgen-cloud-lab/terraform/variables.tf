variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project_name" {
  type    = string
  default = "nextgen-devsecops-ai-lab"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "student_id" {
  type    = string
  default = "student01"
}

variable "lab_volume_size" {
  type    = number
  default = 20
}

variable "admin_api_key" {
  description = "Pilot-only API key. Do not commit the tfvars file."
  type        = string
  sensitive   = true
}

variable "student_username" {
  type    = string
  default = "student01"
}

variable "student_password_hash" {
  description = "SHA-256 hex hash of the pilot student's password."
  type        = string
  sensitive   = true
}
