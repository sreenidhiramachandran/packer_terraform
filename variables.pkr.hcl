locals {
  image-timestamp = "${formatdate("DD-MM-YYYY-hh-mm", timestamp())}"
  image-name = "${var.project}-${var.environment}-${local.image-timestamp}"
}

variable "project" {
  type = string
  default = "packer"
}

variable "environment" {
  type = string
 default = "production"
}

variable "access_key" {
  type = string
  default = "YOUR_ACCESS_KEY"
}

variable "secret_key" {
  type = string
  default = "YOUR_SECRET_KEY"
}

variable "regions" {
  type = map(string)
  default = {
    "region1" = "ap-south-1"
    "region2" = "us-east-2"
  }
}

variable "ami" {
  type = map(string)
  default = {
    "ap-south-1" = "ami-0cca134ec43cf708f"
    "us-east-2" = "ami-0a606d8395a538502"
  }
}
