##########################
##Variable.tf###

variable "vpc_id" {
  default = ""
}


#################
## Variable.tf ##
variable "rules" {
  type = list(object({
    port        = number
    protocol       = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      port        = 80
      protocol       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 22
      protocol       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}