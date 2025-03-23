variable "project_name" {
  description = "The name of the project for tagging and resource naming."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the EC2 instance will be deployed."
  type        = string
}

variable "public_subnet_id" {
  description = "The public subnet ID where the EC2 instance will be launched."
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "The name of the SSH key pair to use for the EC2 instance."
  type        = string
  default     = "demo1_key"
}

variable "entry_point_script" {
  description = "The file path for the user data script for instance bootstrapping."
  type        = string
}

variable "provisioner_script" {
  description = "The file path for the script to execute on the instance using provisioners."
  type        = string
}

variable "eks_dependency" {
  description = "Dependency on the EKS module to ensure the EC2 instance is created after the EKS cluster is up."
  type        = any
}



# variable "rds_endpoint" {
#   description = "RDS endpoint"
#   type        = string
# }

# variable "rds_port" {
#   description = "RDS port"
#   type        = string
# }

# variable "rds_user" {
#   description = "RDS username"
#   type        = string
# }

# variable "rds_password" {
#   description = "RDS password"
#   type        = string
# }

# variable "rds_db_name" {
#   description = "RDS database name"
#   type        = string
# }

# variable "create_table_sql_path" {
#   description = "Path to the create_table.sql file"
#   type        = string
#   default     = "./create_table.sql"
# }
