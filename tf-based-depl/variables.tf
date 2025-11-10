variable "project_id" { type = string }
variable "region" { type = string }
variable "repository_id" { type = string }
variable "build_service_account_email" { type = string } # SA that will push images


variable "project_id" { type = string }
variable "region" { type = string }
variable "cluster_name" { type = string }
variable "node_count" { type = number }
variable "node_machine_type" { type = string }
variable "node_service_account_email" { type = string } # node SA
