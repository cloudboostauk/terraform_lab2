#################
##output.tf##

output "web_instance_ip" {
  description = "Web instance complete URL"
  value = join("", ["http://", aws_instance.cba_tf_instance.public_ip])
}

#################

output "Time-Date" {
  description = "Date/Time of Execution"
  value       = timestamp()
}


#################
## main.tf ##

data "aws_region" "current" {}

#################
## output.tf ##

output "Region" {
  description = "Region"
  value       = data.aws_region.current
}