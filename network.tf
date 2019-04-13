resource "aws_vpc" "openvas-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "openvas-vpc"
  }
}

resource "aws_internet_gateway" "openvas-igw" {
  vpc_id = "${aws_vpc.openvas-vpc.id}"

  tags = {
    Name = "openvas-igw"
  }
}

resource "aws_default_route_table" "openvas-rt-public" {
  default_route_table_id = "${aws_vpc.openvas-vpc.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.openvas-igw.id}"
  }

  tags = {
    Name = "openvas-rt-public"
  }
}

resource "aws_subnet" "openvas-sn-us-west-2a" {
  cidr_block              = "${cidrsubnet(aws_vpc.openvas-vpc.cidr_block, 8, 1)}"
  vpc_id                  = "${aws_vpc.openvas-vpc.id}"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags {
    Name = "openvas-sn-us-west-2a"
  }
}

resource "aws_default_security_group" "openvas-security-group" {
  vpc_id = "${aws_vpc.openvas-vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my-cidr}"]
    description = "SSH access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.my-cidr}"]
    description = "HTTP access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.my-cidr}"]
    description = "HTTPS access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "openvas-security-group"
  }
}
