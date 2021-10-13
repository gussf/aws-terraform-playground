resource "aws_vpc" "new-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "private_subnets" {
  count                   = var.number_of_priv_subnets
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.new-vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-private-subnet-${count.index}"
  }
}


resource "aws_subnet" "public_subnets" {
  count                   = var.number_of_public_subnets
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.new-vpc.id
  cidr_block              = "10.0.${count.index + var.number_of_priv_subnets}.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.prefix}-public-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "new-igw" {
  vpc_id = aws_vpc.new-vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_eip" "eip_nat_gw" {
  count = var.number_of_priv_subnets
  vpc   = true
}


resource "aws_nat_gateway" "nat_gw" {
  count         = length(aws_eip.eip_nat_gw)
  allocation_id = aws_eip.eip_nat_gw[count.index].id
  subnet_id     = aws_subnet.private_subnets[count.index].id

  tags = {
    Name = "${var.prefix}-nat-gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.new-igw]
}

resource "aws_route_table" "pub-rtb" {
  vpc_id = aws_vpc.new-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new-igw.id
  }
  tags = {
    Name = "${var.prefix}-pub-rtb"
  }
}

resource "aws_route_table" "priv-rtb" {
  count = var.number_of_priv_subnets
  vpc_id = aws_vpc.new-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.*.id[count.index]
  }
  tags = {
    Name = "${var.prefix}-priv-rtb"
  }
}


resource "aws_route_table_association" "pub-rtb-association" {
  count          = var.number_of_public_subnets
  route_table_id = aws_route_table.pub-rtb.id
  subnet_id      = aws_subnet.public_subnets.*.id[count.index]
}

resource "aws_route_table_association" "priv-rtb-association" {
  count          = var.number_of_priv_subnets
  route_table_id = aws_route_table.priv-rtb.*.id[count.index]
  subnet_id      = aws_subnet.private_subnets.*.id[count.index]
}


resource "aws_security_group" "default" {
  name        = "${var.prefix}-default-sg"
  description = "Allow all"
  vpc_id      = aws_vpc.new-vpc.id

  ingress = [
    {
      description      = "For all incoming traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false

    }
  ]

  egress = [
    {
      description      = "For all outgoing traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "allow_tls"
  }
}
