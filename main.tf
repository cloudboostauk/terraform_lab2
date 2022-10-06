######Main.tf#######
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  instance_tenancy = "default"
  tags ={
    name = "ApacheVPC"
  }
}

##########################
##Main.tf###
resource "aws_subnet" "cba_public" {
  vpc_id     = aws_vpc.my_vpc
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-west-2a"

  tags = {
    Name = "ApachePublicSubnet"
  }
}

####################
resource "aws_subnet" "cba_private" {
  vpc_id     = aws_vpc.my_vpc
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "us-west-2a"

  tags = {
    Name = "ApachePublicSubnet"
  }
}
##################

resource "aws_internet_gateway" "cba_igw" {
  vpc_id = aws_vpc.cba_vpc.id

  tags = {
    Name = "ApacheIGW"
  }
}

#################
resource "aws_route_table" "cba_public_rt" {
  vpc_id = aws_vpc.cba_vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cba_igw.id
  }

  tags = {
    "Name" = "ApachePublicRT"
  }
  
}

#################

resource "aws_route_table_association" "cba_subnet_rt_public" {
  subnet_id = aws_subnet.cba_public.id
  route_table_id  = aws_route_table.cba_public_rt.id  
}

#################

resource "aws_security_group" "cba_tf_sg" {
  vpc_id = aws_vpc.cba_vpc.id
  name   = "cba_tf_sg"
  dynamic "ingress" {
    for_each = var.rules
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ApacheSG"
  }
}

#################
## main.tf ##
data "aws_ssm_parameter" "instance_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#################

resource "aws_instance" "cba_tf_instance" {
    ami           = data.aws_ssm_parameter.instance_ami.value
    instance_type = var.instane_type
    subnet_id = aws_subnet.cba_public.id
    security_groups = [aws_security_group.cba_tf_sg.id]
    key_name = var.key-name
    user_data = fileexists["imstall_apache.sh"] ? file("install_apache.sh") : null


    tags = {
      "NAME" = "ApacheInstance"
    }
  
}