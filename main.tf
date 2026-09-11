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

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  //instance_type = "t3.micro"   # antes: t3.nano
  instance_type = var.instance_type

  tags = {
    Name = "HelloWorld"
  }
}
