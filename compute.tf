data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "wazuh-vm-us-west-2a" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance-type}"
  subnet_id     = "${aws_subnet.wazuh-sn-us-west-2a.id}"
  key_name      = "${var.key-name}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 100
  }

  tags {
    Name = "wazuh-vm-us-west-2a"
  }
}

resource "aws_eip" "wazuh-eip" {
  instance   = "${aws_instance.wazuh-vm-us-west-2a.id}"
  vpc        = true
  depends_on = ["aws_internet_gateway.wazuh-igw"]

  tags {
    Name = "wazuh-eip"
  }
}
