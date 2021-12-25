##################################################################################
# Data sources
##################################################################################

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.network_state_bucket
    key    = var.network_state_key
    region = var.network_state_region
  }
}

data "aws_ami" "debian_stretch" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name = "name"

    values = [
      "debian-stretch-hvm-x86_64-gp2*",
    ]
  }
}

data "aws_ip_ranges" "ec2_instance_connect" {
  regions  = [var.region]
  services = ["ec2_instance_connect"]
}

resource "aws_security_group" "unifi" {
  name        = "unifi-security-group"
  description = "Security Group for Unifi"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = data.aws_ip_ranges.ec2_instance_connect.cidr_blocks
  }

  ingress {
    description      = "SSH from home"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["70.142.44.29/32"]
  }

  dynamic "ingress" {
    for_each         = var.unifi_ports_tcp
    content{
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      description      = "TCP ingress ports"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  }

  dynamic "ingress" {
    for_each         = var.unifi_ports_udp
    content{
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "udp"
      description      = "UDP ingress ports"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "unifi" {
  name = "unifi-iam-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}

resource "aws_iam_instance_profile" "unifi" {
  name = "unifi-instance-profile"
  role = "${aws_iam_role.unifi.name}"
}

resource "aws_iam_role_policy" "ec2_describe_tags" {
  name = "ec2-describe-tags"
  role = "${aws_iam_role.unifi.name}"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {    
        "Effect": "Allow",
        "Action": [ "ec2:DescribeTags"],
        "Resource": ["*"]
      }
    ]
  })
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "unifi-controller"

  ami                    = data.aws_ami.debian_stretch.id
  instance_type          = "t2.micro"
  iam_instance_profile   = "${aws_iam_instance_profile.unifi.name}"
  key_name               = "Debian-SSH"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.unifi.id]
  subnet_id              = data.terraform_remote_state.network.outputs.public_subnets[0]
  associate_public_ip_address = true
  user_data_base64 = filebase64("${path.module}/startup.sh.gz")

  tags = {
    Terraform   = "true"
    Environment = "unifi"
    Team        = "infra"
    ddns-url = var.ddns_url
    timezone = var.timezone
    dns-name = var.dns_name
    bucket = var.network_state_bucket
  }
}