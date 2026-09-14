data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    //values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
    values = ["al2023-ami-*-x86_64"]

  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  //owners = ["979382823631"] # Bitnami
  owners = ["137112412989"] # Amazon
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  //instance_type = "t3.micro"   # antes: t3.nano
  instance_type = var.instance_type

  //vpc_security_group_ids = [aws_security_group.blog.id]
  vpc_security_group_ids = [module.blog_sg.name]

  tags = {
    Name = "Learning Terraform"
  }
}

module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"
  name = "blog_new"


  vpc_id         = data.aws_vpc.default.id
  ingress_rules  = {
    http = {
      from_port       = 80
      to_port         = 80
      ip_protocol     = "tcp"
      cidr_ipv4       = "0.0.0.0/0"
    }
    https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

}

resource "aws_security_group" "blog" {
  name        = "blog"
  description = "Allow http and https in. Allow everithing out"

  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "blog_http_in" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}

resource "aws_security_group_rule" "blog_https_in" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}

resource "aws_security_group_rule" "blog_everything_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}