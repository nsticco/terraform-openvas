resource "aws_vpc" "wazuh-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "wazuh-vpc"
  }
}

resource "aws_internet_gateway" "wazuh-igw" {
  vpc_id = "${aws_vpc.wazuh-vpc.id}"

  tags = {
    Name = "wazuh-igw"
  }
}

resource "aws_default_route_table" "wazuh-rt-public" {
  default_route_table_id = "${aws_vpc.wazuh-vpc.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.wazuh-igw.id}"
  }

  tags = {
    Name = "wazuh-rt-public"
  }
}

resource "aws_subnet" "wazuh-sn-us-west-2a" {
  cidr_block              = "${cidrsubnet(aws_vpc.wazuh-vpc.cidr_block, 8, 1)}"
  vpc_id                  = "${aws_vpc.wazuh-vpc.id}"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags {
    Name = "wazuh-sn-us-west-2a"
  }
}

resource "aws_default_security_group" "wazuh-security-group" {
  vpc_id = "${aws_vpc.wazuh-vpc.id}"

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

  ingress {
    from_port   = 514
    to_port     = 514
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Wazuh collected events from syslog"
  }

  ingress {
    from_port   = 1514
    to_port     = 1514
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Wazuh agent event collection"
  }

  ingress {
    from_port   = 1515
    to_port     = 1515
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Wazuh agent registration"
  }

  ingress {
    from_port   = 1516
    to_port     = 1516
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Wazuh cluster communications"
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Logstash access"
  }

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kibana web interface"
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Elasticsearch RESTful API"
  }

  ingress {
    from_port   = 9300
    to_port     = 9400
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Elasticsearch cluster communications"
  }

  ingress {
    from_port   = 55000
    to_port     = 55000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Wazuh API HTTP requests"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wazuh-security-group"
  }
}
