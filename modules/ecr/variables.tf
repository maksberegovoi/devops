variable "ecr_name" {
  type    = string
  default = "lesson-5-ecr"
}

variable "scan_on_push" {
  type    = bool
  default = true
}