resource "aws_vpc" "vpc_tuter" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "tutorial"
  }
}

resource "aws_subnet" "vpc_tuter_subnet" {
  vpc_id = "${aws_vpc.vpc_tuter.id}"
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-2b"
}

resource "aws_subnet" "vpc_tuter_subnet_another" {
  vpc_id = "${aws_vpc.vpc_tuter.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2c"
}
resource "aws_internet_gateway" "vpc_tuter_gateway" {
  vpc_id = "${aws_vpc.vpc_tuter.id}"
}

resource "aws_route_table" "vpc_tuter_route_table" {
  vpc_id = "${aws_vpc.vpc_tuter.id}"
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc_tuter_gateway.id}"
  }
}

resource "aws_main_route_table_association" "vpc_tuter_association" {
  vpc_id = "${aws_vpc.vpc_tuter.id}"
  route_table_id = "${aws_route_table.vpc_tuter_route_table.id}"
}

resource "aws_security_group" "vpc_tuter_security_group" {
  name = "Allow http,ssh"
  description = "Allow http,ssh access"
  vpc_id = "${aws_vpc.vpc_tuter.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
